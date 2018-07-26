package com.example.gargui3.faltanchelas;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.List;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;

public class Calificar extends AppCompatActivity {

    private SocketIO socket;
    private JSONObject orderActual;
    private String rol;
    private String order_id;
    private String user_id;
    private String token;
    private String ip;
    private Activity activity;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        this.socket = SocketIO.getInstance();
        if(!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this);
        }else {
            this.socket.setActivity(this);
        }
        this.socket.backReturn("Calificar");
        this.orderActual = this.socket.getOrderActual();

        SharedPreferences prefs = this.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        this.rol = prefs.getString("rol", "sinrol");
        this.token = prefs.getString("token", "sintoken");

        this.ip = this.getString(R.string.ipaddress);

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_calificar);

        this.activity = this;

        TextView txtUsuario = (TextView) findViewById(R.id.nombreUsuarioCalificar);
        TextView txtTipo = (TextView) findViewById(R.id.calificaUsuario);

        String name = "";

        if (rol.equals("user")){
            txtTipo.setText("Califica a tu repartidor");
            try {
                order_id = orderActual.getString("_id");
                JSONObject vendor = orderActual.getJSONObject("vendor_id");
                user_id = vendor.getString("_id");
                name = vendor.getString("name");
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }else if(rol.equals("vendor")) {
            txtTipo.setText("Califica a tu cliente");
            try {
                order_id = orderActual.getString("_id");
                JSONObject user = orderActual.getJSONObject("user_id");
                user_id = user.getString("_id");
                name = user.getString("name");
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        Boolean isPaid = true;
        try {
            isPaid = this.orderActual.getBoolean("isPaid");
        } catch (JSONException e) {
            e.printStackTrace();
        }

        if(!isPaid) {
            new AlertDialog.Builder(this)
                    .setTitle("Erro al procesar el pago")
                    .setMessage(this.getString(R.string.notPaidAcceptedException))
                    .setIcon(android.R.drawable.stat_notify_error)
                    .setPositiveButton("OK", null).show();
        }else {
            new AlertDialog.Builder(this)
                    .setTitle("Pago procesado")
                    .setMessage("Pago procesado correctamente")
                    .setIcon(android.R.drawable.stat_notify_more)
                    .setPositiveButton("OK", null).show();
        }

        txtUsuario.setText(name);

    }

    @Override
    public void onRestart(){
        super.onRestart();
        this.socket.conectar(this.getString(R.string.ipaddress));
    }

    public void calificarUsuario(int calificacion, View v){

        Internet i = new Internet();


        if(i.verificaConexion(this)) {

            StringEntity entity = null;
            JSONObject calf = new JSONObject();
            try {
                calf.put("user_id", user_id);
                calf.put("rate", calificacion);
                entity = new StringEntity(calf.toString());
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            } catch (JSONException e) {
                e.printStackTrace();
            }

            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.post(context, ip + "/rateuser", entity, "application/json",new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                    SharedPreferences prefs = getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
                    SharedPreferences.Editor editor = prefs.edit();
                    editor.putString("isCalifico", "true");
                    editor.commit();
                    socket.setIsCalifico("true");

                    socket.ratedUser(order_id, user_id);

                    Intent i = new Intent(activity, MainActivity.class);
                    startActivity(i);

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

    public void uno(View view){
        ImageView img1t = (ImageView) findViewById(R.id.uno);
        img1t.setImageResource(R.mipmap.fullbeer);
        ImageView img2t = (ImageView) findViewById(R.id.dos);
        img2t.setImageResource(R.mipmap.fullbeer);
        ImageView img3t = (ImageView) findViewById(R.id.tres);
        img3t.setImageResource(R.mipmap.fullbeer);
        ImageView img4t = (ImageView) findViewById(R.id.cuatro);
        img4t.setImageResource(R.mipmap.fullbeer);
        ImageView img5t = (ImageView) findViewById(R.id.cinco);
        img5t.setImageResource(R.mipmap.fullbeer);


        ImageView img1 = (ImageView) findViewById(R.id.uno);
        img1.setImageResource(R.mipmap.fullbeergood);

        calificarUsuario(1, view);

    }

    public void dos(View view){
        ImageView img1t = (ImageView) findViewById(R.id.uno);
        img1t.setImageResource(R.mipmap.fullbeer);
        ImageView img2t = (ImageView) findViewById(R.id.dos);
        img2t.setImageResource(R.mipmap.fullbeer);
        ImageView img3t = (ImageView) findViewById(R.id.tres);
        img3t.setImageResource(R.mipmap.fullbeer);
        ImageView img4t = (ImageView) findViewById(R.id.cuatro);
        img4t.setImageResource(R.mipmap.fullbeer);
        ImageView img5t = (ImageView) findViewById(R.id.cinco);
        img5t.setImageResource(R.mipmap.fullbeer);


        ImageView img1 = (ImageView) findViewById(R.id.uno);
        img1.setImageResource(R.mipmap.fullbeergood);
        ImageView img2 = (ImageView) findViewById(R.id.dos);
        img2.setImageResource(R.mipmap.fullbeergood);

        calificarUsuario(2, view);

    }

    public void tres(View view){
        ImageView img1t = (ImageView) findViewById(R.id.uno);
        img1t.setImageResource(R.mipmap.fullbeer);
        ImageView img2t = (ImageView) findViewById(R.id.dos);
        img2t.setImageResource(R.mipmap.fullbeer);
        ImageView img3t = (ImageView) findViewById(R.id.tres);
        img3t.setImageResource(R.mipmap.fullbeer);
        ImageView img4t = (ImageView) findViewById(R.id.cuatro);
        img4t.setImageResource(R.mipmap.fullbeer);
        ImageView img5t = (ImageView) findViewById(R.id.cinco);
        img5t.setImageResource(R.mipmap.fullbeer);



        ImageView img1 = (ImageView) findViewById(R.id.uno);
        img1.setImageResource(R.mipmap.fullbeergood);
        ImageView img2 = (ImageView) findViewById(R.id.dos);
        img2.setImageResource(R.mipmap.fullbeergood);
        ImageView img3 = (ImageView) findViewById(R.id.tres);
        img3.setImageResource(R.mipmap.fullbeergood);

        calificarUsuario(3, view);

    }

    public void cuatro(View view){
        ImageView img1t = (ImageView) findViewById(R.id.uno);
        img1t.setImageResource(R.mipmap.fullbeer);
        ImageView img2t = (ImageView) findViewById(R.id.dos);
        img2t.setImageResource(R.mipmap.fullbeer);
        ImageView img3t = (ImageView) findViewById(R.id.tres);
        img3t.setImageResource(R.mipmap.fullbeer);
        ImageView img4t = (ImageView) findViewById(R.id.cuatro);
        img4t.setImageResource(R.mipmap.fullbeer);
        ImageView img5t = (ImageView) findViewById(R.id.cinco);
        img5t.setImageResource(R.mipmap.fullbeer);


        ImageView img1 = (ImageView) findViewById(R.id.uno);
        img1.setImageResource(R.mipmap.fullbeergood);
        ImageView img2 = (ImageView) findViewById(R.id.dos);
        img2.setImageResource(R.mipmap.fullbeergood);
        ImageView img3 = (ImageView) findViewById(R.id.tres);
        img3.setImageResource(R.mipmap.fullbeergood);
        ImageView img4 = (ImageView) findViewById(R.id.cuatro);
        img4.setImageResource(R.mipmap.fullbeergood);

        calificarUsuario(4, view);

    }

    public void cinco(View view){
        ImageView img1t = (ImageView) findViewById(R.id.uno);
        img1t.setImageResource(R.mipmap.fullbeer);
        ImageView img2t = (ImageView) findViewById(R.id.dos);
        img2t.setImageResource(R.mipmap.fullbeer);
        ImageView img3t = (ImageView) findViewById(R.id.tres);
        img3t.setImageResource(R.mipmap.fullbeer);
        ImageView img4t = (ImageView) findViewById(R.id.cuatro);
        img4t.setImageResource(R.mipmap.fullbeer);
        ImageView img5t = (ImageView) findViewById(R.id.cinco);
        img5t.setImageResource(R.mipmap.fullbeer);


        ImageView img1 = (ImageView) findViewById(R.id.uno);
        img1.setImageResource(R.mipmap.fullbeergood);
        ImageView img2 = (ImageView) findViewById(R.id.dos);
        img2.setImageResource(R.mipmap.fullbeergood);
        ImageView img3 = (ImageView) findViewById(R.id.tres);
        img3.setImageResource(R.mipmap.fullbeergood);
        ImageView img4 = (ImageView) findViewById(R.id.cuatro);
        img4.setImageResource(R.mipmap.fullbeergood);
        ImageView img5 = (ImageView) findViewById(R.id.cinco);
        img5.setImageResource(R.mipmap.fullbeergood);

        calificarUsuario(5, view);

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
