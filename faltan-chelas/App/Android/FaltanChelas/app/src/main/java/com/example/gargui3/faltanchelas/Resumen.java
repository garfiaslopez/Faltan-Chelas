package com.example.gargui3.faltanchelas;

import android.app.Activity;
import android.app.ActivityManager;
import android.app.Dialog;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

import Adaptadores.AdaptadorPedido;
import Adaptadores.AdaptadorTarjetas;
import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;
import io.conekta.conektasdk.Card;
import io.conekta.conektasdk.Conekta;
import io.conekta.conektasdk.Token;
import modelo.Cerveza;
import modelo.Tarjeta;

public class Resumen extends AppCompatActivity {

    private Tarjeta tarjeta;
    private ImageView v = null;
    private Cerveza[] pedido;
    private Double subtotal;
    private Double costoEnvio;
    private Double total;
    private String token;
    private String ip;
    private SocketIO socket;
    private String userID;
    private double lat;
    private double lng;
    private String direccionEnvio;
    private String order_id;
    private Button btnModalTarjeta;
    private EditText txtObservaciones;

    private Activity activity = this;

    private Tarjeta[] t;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        this.socket = SocketIO.getInstance();
        if(!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this);
        }else {
            this.socket.setActivity(this);
        }
        this.socket.updateView();

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_resumen);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        ArrayList<Cerveza> c = (ArrayList<Cerveza>) getIntent().getSerializableExtra("vendido");
        this.subtotal = getIntent().getExtras().getDouble("subtotal");
        this.costoEnvio = getIntent().getExtras().getDouble("costoEnvio");
        this.total = getIntent().getExtras().getDouble("total");
        this.lat = getIntent().getExtras().getDouble("latitude");
        this.lng = getIntent().getExtras().getDouble("longitude");
        this.direccionEnvio = getIntent().getExtras().getString("direccionEnvio");

        SharedPreferences prefs = this.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        this.token = prefs.getString("token", "sintoken");
        this.userID = prefs.getString("userID", "sinID");
        this.ip = this.getString(R.string.ipaddress);

        getTarjetas();

        int cont = 0;

        for(Cerveza c1: c){
            if(c1 != null){
                cont++;
            }
        }

        Cerveza[] datos = new Cerveza[cont];

        int i=0;
        for(Cerveza c1: c){
            if(c1 != null){
                datos[i] = c1;
                i++;
            }
        }

        this.pedido = datos;

        AdaptadorPedido adaptador =
                new AdaptadorPedido(this, datos);

        final ListView lstOpciones = (ListView)findViewById(R.id.listaPedido);

        lstOpciones.setAdapter(adaptador);

        TextView txtSubtotal = (TextView) findViewById(R.id.subtotalPedido);
        txtSubtotal.setText("$" + subtotal);

        TextView txtCostoEnvio = (TextView) findViewById(R.id.costoEnvioPedido);
        txtCostoEnvio.setText("$" + costoEnvio);

        TextView txtTotal = (TextView) findViewById(R.id.totalPedido);
        txtTotal.setText("$" + total);

        this.btnModalTarjeta = (Button) this.findViewById(R.id.modalTarjetaResumen);
        this.btnModalTarjeta.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                agregarTarjeta(v);
            }
        });
        this.txtObservaciones = (EditText) findViewById(R.id.descriptionObservaciones);


    }

    @Override
    public void onRestart(){
        super.onRestart();
        this.socket.conectar(this.getString(R.string.ipaddress));
    }

    public void crearTarjeta(String name, String numTarjeta, String CVC, String mes, String ano, final Dialog d, final View view){
        Conekta.setPublicKey(this.getString(R.string.conektaPublicKey)); //Set public key
        Conekta.setApiVersion("1.0.0"); //Set api version (optional)
        Conekta.collectDevice(this); //Collect device

        Card card = new Card(name, numTarjeta, CVC, mes, ano);
        Token token = new Token(this);

        token.onCreateTokenListener( new Token.CreateToken(){
            @Override
            public void onCreateTokenReady(JSONObject data) {
                try {
                    //TODO: Create charge
                    String tkn = data.getString("id");
                    System.out.println("Token: " + data.getString("id"));
                    guardarTarjeta(tkn, d, view);
                } catch (Exception err) {
                    //TODO: Handle error
                    System.out.println("Error: " + err.toString());
                }
            }
        });

        token.create(card);
    }

    public void guardarTarjeta(final String tkn, final Dialog d, final View v){
        Internet i = new Internet();

        if(i.verificaConexion(this)){

            SharedPreferences prefs = this.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
            String id = prefs.getString("userID", "sinID");

            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                params.put("user_id", id);
                params.put("card_token", tkn);
                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.post(context, ip + "/conekta/card", entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                    Boolean valor = null;
                    Object msj = null;
                    try {
                        valor = response.getBoolean("success");
                        msj = response.get("message");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    if (valor == true) {

                        d.dismiss();
                        getTarjetas();
                        Snackbar.make(v, "Agregado Correctamente", Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();

                    } else {
                        d.dismiss();
                        Snackbar.make(v, msj.toString(), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }

                }

            });
        }else{
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }

    }

    public void agregarTarjeta(final View view){
        final Dialog dialog = new Dialog(view.getContext());
        dialog.setContentView(R.layout.dialog_agregar_tarjeta);
        dialog.setTitle("Agregar Tarjeta");

        Button dialogButton = (Button) dialog.findViewById(R.id.agregarTarjeta);
        // if button is clicked, close the custom dialog
        dialogButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                EditText name = (EditText) dialog.findViewById(R.id.nameTarjeta);
                EditText numTarjeta = (EditText) dialog.findViewById(R.id.numeroTarjeta);
                EditText CVC = (EditText) dialog.findViewById(R.id.codigoTarjeta);
                EditText mes = (EditText) dialog.findViewById(R.id.mesTarjeta);
                EditText ano = (EditText) dialog.findViewById(R.id.anoTarjeta);
                crearTarjeta(name.getText().toString(), numTarjeta.getText().toString(), CVC.getText().toString(), mes.getText().toString(), ano.getText().toString(), dialog, view);
            }
        });

        dialog.show();

    }

    public void createListTarjetas(){
        AdaptadorTarjetas adaptadorTarjetas =
                new AdaptadorTarjetas(this, t, this);

        final ListView lstOpciones2 = (ListView)findViewById(R.id.listaTarjetas);

        lstOpciones2.setAdapter(adaptadorTarjetas);
    }

    public void getTarjetas(){
        Internet i = new Internet();

        if(i.verificaConexion(this)) {

            System.out.println("Entro a actualizar perfil");

            SharedPreferences prefs = this.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
            String id = prefs.getString("userID", "sinID");

            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.get(context, ip + "/conekta/cards/" + id, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONArray cards = null;
                    try {
                        cards = response.getJSONArray("cards");
                        t = new Tarjeta[cards.length()];
                        for(int i = 0; i < cards.length(); i++)
                        {
                            try {
                                JSONObject tarjeta = cards.getJSONObject(i);
                                Tarjeta t1 = new Tarjeta();
                                t1.setTipoTarjeta(tarjeta.getString("brand"));
                                t1.setNumTarjeta(tarjeta.getString("last4"));
                                t1.setToken(tarjeta.getString("id"));
                                t[i] = t1;
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                        }
                        if(cards.length() > 0){
                            btnModalTarjeta.setVisibility(View.INVISIBLE);
                        }else{
                            btnModalTarjeta.setVisibility(View.VISIBLE);
                        }
                        createListTarjetas();
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    System.out.println("No se pudieron obtener tarjetas");
                }


            });
        } else {
            System.out.println("sin tarjetas");
        }
    }

    public void setTarjeta(Tarjeta tarjeta, ImageView v){
        if(this.tarjeta != null) {
            if (this.tarjeta.getToken() == tarjeta.getToken()) {
                this.tarjeta = null;
                this.v.setVisibility(View.INVISIBLE);
            } else {
                this.tarjeta = tarjeta;
                if (this.v != null) {
                    this.v.setVisibility(View.INVISIBLE);
                }
                this.v = v;
                this.v.setVisibility(View.VISIBLE);
            }
        }else{
            this.tarjeta = tarjeta;
            if (this.v != null) {
                this.v.setVisibility(View.INVISIBLE);
            }
            this.v = v;
            this.v.setVisibility(View.VISIBLE);
        }
    }

    public void crearOrden(){

        JSONObject order = new JSONObject();
        JSONObject destiny = new JSONObject();

        JSONArray products = new JSONArray();

        for (int i=0; i<pedido.length; i++){
            JSONObject product = new JSONObject();
            Cerveza c = pedido[i];
            System.out.println("The fucking name: " + c.getMarca());
            try {
                product.put("denomination", c.getMarca());
                product.put("price", c.getPrecio());
                product.put("quantity", c.getPack());
                product.put("units", c.getCantidad());
                System.out.println(product);
                products.put(product);
                System.out.println(products);
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        try {

            destiny.put("denomination", direccionEnvio);
            destiny.put("lat", lat);
            destiny.put("long", lng);

            order.put("products", products);
            order.put("user_id", this.userID);
            order.put("total", this.total);
            order.put("destiny", destiny);
            order.put("paymethod", tarjeta.getToken());
            if(!txtObservaciones.getText().equals(""))
                order.put("aditionalInfo", txtObservaciones.getText());
            System.out.println("Tarjeta: " + tarjeta.getToken());
        } catch (JSONException e) {
            e.printStackTrace();
        }

        sendOrder(order);

    }

    public void sendOrder(JSONObject order){
        Internet i = new Internet();


        if(i.verificaConexion(this)) {

            System.out.println(order);

            StringEntity entity = null;
            try {
                entity = new StringEntity(order.toString());
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.post(context, ip + "/order", entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONObject order;
                    try {
                        order = response.getJSONObject("order");
                        order_id = order.getString("_id");
                        socket.sendOrder(order_id, userID);

                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    System.out.println(error.getLocalizedMessage());
                    System.out.println(response.toString());
                    System.out.println(statusCode);
                }


            });
        } else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void ordenar(View view){
        if(this.tarjeta != null){
            crearOrden();
            //crearTarjeta();
        }else {
            Snackbar.make(view, getString(R.string.sinTarjetaException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
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
