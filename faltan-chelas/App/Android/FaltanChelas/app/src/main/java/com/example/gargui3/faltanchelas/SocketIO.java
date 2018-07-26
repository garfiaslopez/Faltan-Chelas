package com.example.gargui3.faltanchelas;

/**
 * Created by gargui3 on 20/06/16.
 */
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.design.widget.Snackbar;
import android.view.View;
import android.widget.EditText;

/*import com.github.nkzawa.emitter.Emitter;
import com.github.nkzawa.socketio.client.IO;
import com.github.nkzawa.socketio.client.Socket;*/

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
import java.net.URISyntaxException;

import cz.msebera.android.httpclient.Header;
import io.socket.client.IO;
import io.socket.client.Socket;
import io.socket.emitter.Emitter;

public class SocketIO implements Serializable{

    private static SocketIO INSTANCE = null;

    private Socket socket;
    private Activity activity;
    private String status;
    private JSONObject orderActual;
    private Boolean error = false;
    private Boolean notAccepted = false;
    private Boolean activo = false;
    private Boolean firstOpen;
    private Boolean isEnded = false;
    private String isCalifico;

    private SocketIO(){}

    private synchronized static void createInstance() {
        if (INSTANCE == null) {
            System.out.println("Se creo la unica instancia");
            INSTANCE = new SocketIO();
        }
    }

    public static SocketIO getInstance(){
        if(INSTANCE == null) createInstance();
        return INSTANCE;
    }

    public void conectar(String ipaddress){
        this.firstOpen = true;
        if(socket == null) {
            System.out.println("Entro a conectar al volver en nulo");
            try {
                this.socket = IO.socket(ipaddress);
            } catch (URISyntaxException e) {
            }

            metodosON();
            socket.connect();

        }else {
            System.out.println("Entro a conectar al volver");
            if (!socket.connected()) {

                System.out.println("Entro a conectar al volver y en falso");

                try {
                    this.socket = IO.socket(ipaddress);
                } catch (URISyntaxException e) {
                }

                metodosON();
                socket.connect();

            }
        }
    }

    public void setOrderActual(JSONObject orderActual){
        this.orderActual = orderActual;
    }

    public void inicializar(String ipaddress, Activity activity) {

        this.activity = activity;
        this.activo = true;
        this.firstOpen = true;

        if(socket == null) {
            System.out.println("entro a nulo");
            try {
                this.socket = IO.socket(ipaddress);
            } catch (URISyntaxException e) {
            }

            metodosON();
            socket.connect();

        }else {
            if (!socket.connected()) {

                System.out.println("entro a conectar");

                try {
                    this.socket = IO.socket(ipaddress);
                } catch (URISyntaxException e) {
                }

                metodosON();
                socket.connect();

            }
        }

    }

    public void metodosON(){
        socket.on("HowYouAre", new Emitter.Listener() {

            @Override
            public void call(Object... args) {
                System.out.println("entro a how you are");
                usuarioConectado();
            }

        });

        socket.on("UpdateOrder", new Emitter.Listener() {

            @Override
            public void call(Object... args) {
                JSONObject order = (JSONObject) args[0];
                try {
                    if(order != null) {
                        System.out.println("Entro a update order");
                        orderActual = order;
                        String status = order.getString("status");
                        System.out.println("Status: " + status);
                        switchViews(status);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }

        });

        socket.on("ErrorOrder", new Emitter.Listener() {

            @Override
            public void call(Object... args) {

                error = true;
                switchViews("ErrorOrder");

            }

        });
    }

    public Boolean getActivo(){
        return this.activo;
    }

    public Boolean getError(){
        return this.error;
    }

    public void setError(Boolean error){
        this.error = error;
    }

    public Boolean getNotAccepted(){
        return this.notAccepted;
    }

    public void setNotAccepted(Boolean notAccepted){
        this.notAccepted = notAccepted;
    }

    public JSONObject getOrderActual(){
        return orderActual;
    }

    public void acceptOrder(String order_id, String user_id){
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("AcceptOrder", order);
    }

    public void deliverOrder(String order_id, String user_id){
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("DeliverOrder", order);
    }

    public void ratedUser(String order_id, String user_id){
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("RatedUser", order);
    }

    public void updateView(){
        if(this.status == null){

        }else if(this.status.equals("Searching")){
            Intent intent = new Intent(activity, Buscando.class);
            intent.putExtra("ordenID", "sinorden");
            activity.startActivity(intent);
        }else if(this.status.equals("Accepted")){
            Intent intent = new Intent(activity, Encamino.class);
            activity.startActivity(intent);
        }else if(this.status.equals("Delivered")){
            Intent intent = new Intent(activity, Calificar.class);
            activity.startActivity(intent);
        }
    }

    public void backReturn(String procedente){
        if(this.status == null){
            this.status = "Calificar";
        }
        if(procedente.equals("Buscando")){
            if(this.status.equals("Accepted")) {
                Intent intent = new Intent(activity, Encamino.class);
                activity.startActivity(intent);
            }
        }
        if(procedente.equals("Encamino")){
            if(this.status.equals("Delivered")) {
                Intent intent = new Intent(activity, Calificar.class);
                activity.startActivity(intent);
            }
        }
        if(procedente.equals("Calificar")){
            if(this.status.equals("Normal")) {
                Intent intent = new Intent(activity, MainActivity.class);
                activity.startActivity(intent);
            }
        }
    }

    public void isEnded(){
        this.isEnded = true;
        this.socket.disconnect();
    }

    public void setActivity(Activity activity){

        if(isEnded){
            this.isEnded = false;
        }

        this.activity = activity;

    }

    public void setIsCalifico(String des){
        this.isCalifico = des;
    }

    public void switchViews(String status){

        this.status = status;

        if(this.isCalifico.equals("false")){
            Intent intent = new Intent(activity, Calificar.class);
            activity.startActivity(intent);
        }else {

            if (status.equals("Searching")) {
                Intent intent = new Intent(activity, Buscando.class);
                intent.putExtra("ordenID", "sinorden");
                activity.startActivity(intent);
            } else if (status.equals("Accepted")) {
                Intent intent = new Intent(activity, Encamino.class);
                activity.startActivity(intent);
            } else if (status.equals("Delivered")) {
                SharedPreferences prefs = activity.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
                SharedPreferences.Editor editor = prefs.edit();
                editor.putString("isCalifico", "false");
                editor.commit();
                this.isCalifico = "false";
                Intent intent = new Intent(activity, Calificar.class);
                activity.startActivity(intent);
            }
            if (!firstOpen) {

                if (status.equals("ErrorOrder")) {
                    Intent intent = new Intent(activity, MainActivity.class);
                    activity.startActivity(intent);
                } else if (status.equals("NoAccepted")) {
                    notAccepted = true;
                    Intent intent = new Intent(activity, MainActivity.class);
                    activity.startActivity(intent);
                }
            } else {
                this.firstOpen = false;
            }
        }

    }



    public void usuarioConectado() {

        SharedPreferences prefs = activity.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        String id = prefs.getString("userID", "sinID");
        String rol = prefs.getString("rol", "sinrol");
        String correo = prefs.getString("correo", "sincorreo");
        this.isCalifico = prefs.getString("isCalifico", "nada");

        JSONObject datos = new JSONObject();
        System.out.println("Role: " + rol);
        try {
            datos.put("user_id", id);
            datos.put("email", correo);
            datos.put("typeuser", rol);
            datos.put("device", "Android");
        } catch (JSONException e) {
            e.printStackTrace();
        }

        System.out.println("ID: " + id);

        socket.emit("ConnectedUser", datos);

    }

    public void sendOrder(String order_id, String user_id) {

        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("SearchForVendor", order);
    }

    //Al cancelar un pedido solicitado
    public void rejectOrder(String order_id, String user_id){
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("RejectOrder", order);
    }

    //Al abrir la vista del pedido
    public void openNotification(String order_id, String user_id){
        JSONObject order = new JSONObject();
        try {
            order.put("order_id", order_id);
            order.put("user_id", user_id);
        } catch (JSONException e) {
            e.printStackTrace();
        }

        socket.emit("OpenOrder", order);
    }

}
