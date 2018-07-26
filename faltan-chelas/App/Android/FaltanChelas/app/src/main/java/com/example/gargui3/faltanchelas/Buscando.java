package com.example.gargui3.faltanchelas;

import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ListView;
import android.widget.TextView;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.List;

import Adaptadores.AdaptadorPedido;
import Adaptadores.AdaptadorPedidoSolicitado;
import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;
import modelo.Cerveza;

public class Buscando extends AppCompatActivity {

    private SocketIO socket;
    private String rol;
    private JSONObject ordenActual;
    private Double subtotal = 0.0;
    private Double total = 0.0;
    private String user_id;
    private String order_id;
    private String ip;
    private String token;
    private String costoEnvio;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        SharedPreferences prefs = this.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        this.rol = prefs.getString("rol", "sinrol");
        costoEnvio = prefs.getString("costo_envio", "20.0");
        this.user_id = prefs.getString("userID", "sinID");
        this.token = prefs.getString("token", "sintoken");
        this.ip = this.getString(R.string.ipaddress);

        this.socket = SocketIO.getInstance();
        if(!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this);
        }else {
            this.socket.setActivity(this);
            this.socket.conectar(this.getString(R.string.ipaddress));
        }

        super.onCreate(savedInstanceState);
        if(rol.equals("user")) {
            this.socket.backReturn("Buscando");
            setContentView(R.layout.activity_buscando);
        }else if(rol.equals("vendor")){
            setContentView(R.layout.activity_solicitar_vendor);

            updateStatus(false);

            String ordenID = getIntent().getExtras().getString("ordenID", "sinorden");
            if(!ordenID.equals("sinorden")) {
                System.out.println("Entro a notificacion orden");
                obtainOrden(ordenID);
            }else {
                System.out.println("lololol");
                this.ordenActual = this.socket.getOrderActual();
                rellenar("normal");
            }



        }

    }

    @Override
    public void onRestart(){
        super.onRestart();
        this.socket.conectar(this.getString(R.string.ipaddress));
    }

    public void rellenar(String tipo){
        JSONArray cervezas = null;
        String info = null;
        try {
            info = this.ordenActual.getString("aditionalInfo");
            cervezas = this.ordenActual.getJSONArray("products");
            this.total = this.ordenActual.getDouble("total");
            this.order_id = this.ordenActual.getString("_id");
        } catch (JSONException e) {
            e.printStackTrace();
        }
        Cerveza[] datos = new Cerveza[cervezas.length()];
        try {
            for(int i=0; i<cervezas.length(); i++){
                System.out.println("entro: " + cervezas.length());
                JSONObject dato = null;
                if (cervezas != null) {
                    dato = cervezas.getJSONObject(i);
                }
                if(dato!=null) {
                    Cerveza c = new Cerveza();
                    c.setMarca(dato.getString("denomination"));
                    c.setCantidad("" + dato.getInt("units"));
                    c.setPrecio("" + dato.getDouble("price"));
                    this.subtotal += dato.getDouble("price");
                    datos[i] = c;
                }

                System.out.println("marca: " + datos[i].getMarca());

            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        AdaptadorPedidoSolicitado adaptador =
                new AdaptadorPedidoSolicitado(this, datos);

        final ListView lstOpciones = (ListView)findViewById(R.id.listaPedidoSolicitada);

        lstOpciones.setAdapter(adaptador);

        TextView txtSubtotal = (TextView) findViewById(R.id.subtotalPedidoSolicitado);
        TextView txtCostoEnvio = (TextView) findViewById(R.id.costoEnvioPedidoSolicitado);
        TextView txtTotal = (TextView) findViewById(R.id.totalPedidoSolicitado);

        txtSubtotal.setText("$" + this.subtotal);
        txtCostoEnvio.setText("$" + costoEnvio);
        txtTotal.setText("$" + this.total);


        try {
            JSONObject user = this.ordenActual.getJSONObject("user_id");
            String name = user.getString("name");
            JSONObject loc = this.ordenActual.getJSONObject("destiny");
            String address = loc.getString("denomination");
            TextView txtUsuario = (TextView) findViewById(R.id.nombreUsuarioSolitante);
            TextView txtTienda = (TextView) findViewById(R.id.direccionSolicitante);
            TextView txtInfo = (TextView) findViewById(R.id.infoAdicional);
            txtUsuario.setText(name);
            txtTienda.setText(address);
            txtInfo.setText(info);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        if(tipo.equals("notificacion")){
            sendOpenNotification();
        }
    }

    public void obtainOrden(String id){
        Internet i = new Internet();

        if(i.verificaConexion(this)) {


            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", this.token);
            client.get(context, ip + "/order/" + id, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONObject orden = null;
                    try {
                        orden = response.getJSONObject("order");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    ordenActual = orden;
                    rellenar("notificacion");
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    System.out.println("Error");
                }


            });
        }
    }

    public void updateStatus(final Boolean status){
        Internet i = new Internet();

        if(i.verificaConexion(this)) {


            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                params.put("available", status);

                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.put(context, ip + "/user/" + this.user_id, entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    System.out.println("Error");
                }


            });
        }
    }

    public void acceptOrder(View view){
        System.out.println("acepte");
        this.socket.acceptOrder(order_id, user_id);
    }

    public void sendOpenNotification(){
        this.socket.openNotification(order_id, user_id);
    }
    public void cancelOrder(View view){
        this.socket.rejectOrder(order_id, user_id);
        Intent i = new Intent(this, MainActivity.class);
        startActivity(i);
    }

    public boolean isForeground(Context context,String appPackageName) {
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();
        if (appProcesses == null) {
            return false;
        }
        final String packageName = appPackageName;
        for (ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
            if (appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND && appProcess.processName.equals(packageName)) {
                //                Log.e("app",appPackageName);
                return true;
            }
        }
        return false;
    }

    @Override
    public void onStop(){
        super.onStop();
        if(!isForeground(this, "com.faltanchelas"))
            this.socket.isEnded();
    }

}
