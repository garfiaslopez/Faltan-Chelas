package com.example.gargui3.faltanchelas;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;

public class RegisterActivity extends AppCompatActivity {

    String ip;

    private static final String emailValido = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
            + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        this.ip = this.getString(R.string.ipaddress);

        setContentView(R.layout.activity_register);
    }

    public void cancel(View view){
        Intent in = new Intent(this, AccessActivity.class);
        this.finish();
        startActivity(in);
    }

    public static boolean validarEmail(String email) {

        // Compiles the given regular expression into a pattern.
        Pattern pattern = Pattern.compile(emailValido);

        // Match the given input against this pattern
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();

    }

    public void signup(View view){

        Internet i = new Internet();
        final View v = view;

        if(i.verificaConexion(this)) {
            EditText nombre = (EditText) findViewById(R.id.nombrePersonal);
            EditText phone = (EditText) findViewById(R.id.phone);
            EditText email = (EditText) findViewById(R.id.email);
            EditText password = (EditText) findViewById(R.id.password);

            final String correo = email.getText().toString();
            final String pass = password.getText().toString();

            if (validarEmail(email.getText().toString())) {

                JSONObject params = new JSONObject();
                StringEntity entity = null;
                try {
                    params.put("name", nombre.getText().toString());
                    params.put("email", email.getText().toString());
                    params.put("password", password.getText().toString());
                    params.put("phone", phone.getText().toString());
                    entity = new StringEntity(params.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }

                Context context = this.getApplicationContext();

                AsyncHttpClient client = new AsyncHttpClient();
                client.post(context, ip + "/user", entity, "application/json", new JsonHttpResponseHandler() {

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


                        // Do something with the response

                        if (valor == true) {
                            iniciarSesion(correo, pass, v);
                        } else {
                            Snackbar.make(v, msj.toString(), Snackbar.LENGTH_LONG)
                                    .setAction("Action", null).show();
                        }

                    }

                });

            } else {
                Snackbar.make(v, this.getString(R.string.correInvalidoException), Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        }else{
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }

    }

    public void iniciarSesion(String email, String password, View view){
        Internet i = new Internet();
        final View v = view;

        if(i.verificaConexion(this)) {


            final Intent intent = new Intent(this, MainActivity.class);


            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                params.put("email", email);
                params.put("password", password);
                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.post(context, ip + "/authenticate", entity, "application/json", new JsonHttpResponseHandler() {


                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                    Boolean valor = null;
                    Object msj = null;
                    Object tkn = null;
                    JSONObject user = null;
                    try {
                        valor = response.getBoolean("success");
                        msj = response.get("message");
                        tkn = response.get("token");
                        user = response.getJSONObject("user");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }


                    // Do something with the response
                    System.out.println(valor);
                    System.out.println("Token: " + tkn);

                    if (valor == true) {
                        JSONObject email;
                        String address = "";
                        String idd = "";
                        String name = "";
                        String rol = "";
                        try {
                            email = user.getJSONObject("email");
                            address = email.getString("address");
                            idd = user.getString("_id");
                            name = user.getString("name");
                            rol = user.getString("typeuser");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        SharedPreferences prefs = getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
                        SharedPreferences.Editor editor = prefs.edit();
                        editor.putString("token", tkn.toString());
                        editor.putString("username", name);
                        editor.putString("correo", address);
                        editor.putString("userID", idd);
                        editor.putString("rol", rol);
                        editor.putString("isCalificado", "true");
                        editor.commit();
                        finish();
                        startActivity(intent);

                    } else {
                        Snackbar.make(v, msj.toString(), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable) {
                    Snackbar.make(v, "No hay servicio por el momento, gracias", Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }
            });
        }else{
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

}
