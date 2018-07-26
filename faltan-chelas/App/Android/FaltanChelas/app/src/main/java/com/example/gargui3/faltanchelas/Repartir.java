package com.example.gargui3.faltanchelas;

import android.content.Context;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;


import java.util.regex.Matcher;
import java.util.regex.Pattern;

import cz.msebera.android.httpclient.Header;


public class Repartir extends AppCompatActivity {

    String ip;
    private static final String emailValido = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
            + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        this.ip = this.getString(R.string.ipaddress);

        setContentView(R.layout.activity_repartir);
    }

    public static boolean validarEmail(String email) {

        // Compiles the given regular expression into a pattern.
        Pattern pattern = Pattern.compile(emailValido);

        // Match the given input against this pattern
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();

    }


    public void enviarDatos(View view){

        Internet i = new Internet();
        final View v = view;
        String url = "https://api.mailgun.net/v3/sandboxc8bfca74f8654582b79205d3a5487403.mailgun.org/messages";
        //String urlTest = "https://api.mailgun.net/v3/sandbox2ce6d41ed3a9454f8927ee32c9d1d181.mailgun.org/messages";


        if(i.verificaConexion(this)) {
            final EditText nombre = (EditText) findViewById(R.id.nombrePersonalSolicitante);
            final EditText phone = (EditText) findViewById(R.id.phoneSolicitante);
            final EditText email = (EditText) findViewById(R.id.emailSolicitante);
            final EditText description = (EditText) findViewById(R.id.descriptionSolicitante);

            if (validarEmail(email.getText().toString())) {

                final RequestParams params = new RequestParams();

                params.put("from", email.getText().toString());
                params.put("to", "contacto@faltanchelas.com");
                params.put("subject", "Solicitud de: " + nombre.getText().toString());
                params.put("text", "Nombre: " + nombre.getText().toString() + "\n\n" + "Correo: " + email.getText().toString() + "\n\n"
                        + "Mensaje: " + description.getText().toString() + "\n\n" + "Celular: " + phone.getText().toString());


                Context context = this.getApplicationContext();

                AsyncHttpClient client = new AsyncHttpClient();
                client.setBasicAuth("api", getString(R.string.keyMailgun));
                client.post(context, url, params, new AsyncHttpResponseHandler() {
                    @Override
                    public void onSuccess(int statusCode, Header[] headers, byte[] responseBody) {
                        email.setText("");
                        email.setHint("Correo");
                        nombre.setText("");
                        nombre.setHint("Nombre");
                        phone.setText("");
                        phone.setHint("Celular");
                        description.setText("");
                        description.setHint("Descripcion");
                        Snackbar.make(v, "Solicitud enviada correctamente", Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }

                    @Override
                    public void onFailure(int statusCode, Header[] headers, byte[] responseBody, Throwable error) {
                        Snackbar.make(v, "La solicitud no se pudo enviar", Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
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

}
