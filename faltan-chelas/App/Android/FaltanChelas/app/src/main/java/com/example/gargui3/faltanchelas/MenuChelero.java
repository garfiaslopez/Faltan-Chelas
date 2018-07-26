package com.example.gargui3.faltanchelas;

import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Parcelable;
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

import java.io.Serializable;
import java.sql.Array;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import Adaptadores.AdaptadorChelas;
import cz.msebera.android.httpclient.Header;
import modelo.Cerveza;
import modelo.Venta;

public class MenuChelero extends AppCompatActivity {

    private Cerveza[] datos;

    private double subtotal;
    private double costoEnvio;
    private double total;
    private Cerveza[] venta;
    private String token;
    private String ip;
    private String direccionEnvio;
    private SocketIO socket;
    private double lat;
    private double lng;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        this.socket = SocketIO.getInstance();
        if(!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this);
        }else {
            this.socket.setActivity(this);
        }
        this.socket.updateView();

        SharedPreferences prefs = this.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        this.token = prefs.getString("token", "sintoken");
        String costoE = prefs.getString("costo_envio", "20.0");

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_menu_chelero);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        this.ip = this.getString(R.string.ipaddress);
        this.direccionEnvio = getIntent().getExtras().getString("direccionEnvio");
        this.lat = getIntent().getExtras().getDouble("latitude");
        this.lng = getIntent().getExtras().getDouble("longitude");


        getProducts();

        TextView subtotal = (TextView) findViewById(R.id.subtotal);
        subtotal.setText("$0");

        TextView costoEnvio = (TextView) findViewById(R.id.costoEnvio);
        costoEnvio.setText("$" + costoE);

        TextView total = (TextView) findViewById(R.id.total);
        total.setText("$0");

    }

    @Override
    public void onRestart(){
        super.onRestart();
        this.socket.conectar(this.getString(R.string.ipaddress));
    }

    public void createList(){
        AdaptadorChelas adaptador =
                new AdaptadorChelas(this, datos, this);

        final ListView lstOpciones = (ListView)findViewById(R.id.lstChelas);

        lstOpciones.setAdapter(adaptador);
    }

    public void getProducts(){
        Internet i = new Internet();

        if(i.verificaConexion(this)) {

            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.get(context, ip + "/product", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONArray products = null;
                    try {
                        products = response.getJSONArray("products");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }


                    datos = new Cerveza[products.length()];
                    for(int i = 0; i < products.length(); i++)
                    {
                        try {
                            JSONObject product = products.getJSONObject(i);
                            Cerveza tmp = new Cerveza();
                            tmp.setMarca(product.getString("denomination"));
                            JSONArray prices = product.getJSONArray("prices");
                            JSONObject price = prices.getJSONObject(0);
                            tmp.setPrecio(price.getString("price"));
                            tmp.setCantidad(price.getString("quantity"));
                            datos[i] = tmp;

                        } catch (JSONException e) {
                            e.printStackTrace();
                        }

                        if(i == products.length()-1){
                            createList();
                        }
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    System.out.println(error.getLocalizedMessage());
                    System.out.println(statusCode);
                }


            });
        } else {
            System.out.println("sin internet");
        }
    }

    public void continuar(View view){
        if(subtotal > 0) {
            Intent intent = new Intent(this, Resumen.class);
            ArrayList<Cerveza> cervezasVendidas = new ArrayList<>(Arrays.asList(venta));
            for(Cerveza tmp: cervezasVendidas){
                if(tmp != null)
                    System.out.println(tmp.getMarca());
            }
            intent.putExtra("vendido", cervezasVendidas);
            intent.putExtra("subtotal", subtotal);
            intent.putExtra("costoEnvio", costoEnvio);
            intent.putExtra("total", total);
            intent.putExtra("direccionEnvio", direccionEnvio);
            intent.putExtra("latitude", lat);
            intent.putExtra("longitude", lng);
            startActivity(intent);
        }else {
            Snackbar.make(view, getString(R.string.ventaMinimaException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void calcular(Venta val, Cerveza[] venta){

        this.venta = venta;
        for(Cerveza tmp: venta){
            if(tmp != null)
                System.out.println(tmp.getMarca());
        }
        SharedPreferences prefs = this.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        String costoE = prefs.getString("costo_envio", "20.0");

        TextView subtotal = (TextView) findViewById(R.id.subtotal);
        double subtotalResult = val.getSubtotal();
        System.out.println(subtotalResult);
        subtotal.setText("$" + subtotalResult);

        TextView costoEnvio = (TextView) findViewById(R.id.costoEnvio);
        costoEnvio.setText("$" + costoE);

        TextView totalTxt = (TextView) findViewById(R.id.total);
        double totalResult = subtotalResult + 20.0;
        totalTxt.setText("$" + totalResult);

        this.total = totalResult;
        this.costoEnvio = Double.parseDouble(costoE);
        this.subtotal = subtotalResult;
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


