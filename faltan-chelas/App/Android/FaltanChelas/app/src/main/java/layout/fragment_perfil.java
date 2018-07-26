package layout;

import android.content.Context;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;

import com.example.gargui3.faltanchelas.Internet;
import com.example.gargui3.faltanchelas.R;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;

public class fragment_perfil extends Fragment {

    ViewGroup rootView;
    String ip;
    String token;

    private static final String emailValido = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
            + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";

    public fragment_perfil() {
        // Required empty public constructor
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        rootView = (ViewGroup) inflater.inflate(R.layout.fragment_perfil, container, false);

        SharedPreferences prefs = this.getActivity().getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        this.ip = this.getString(R.string.ipaddress);
        this.token = prefs.getString("token", "sintoken");

        Button btnActualizar = (Button) rootView.findViewById(R.id.btnActualizarPerfil);

        btnActualizar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                actualizarPerfil(v);
            }
        });

        datosPerfil();

        return rootView;
    }

    public void datosPerfil(){
        Internet i = new Internet();
        final View v = this.getView();


        if(i.verificaConexion(getContext())) {

            System.out.println("Entro a actualizar perfil");

            SharedPreferences prefs = this.getActivity().getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
            String id = prefs.getString("userID", "sinID");

            final EditText txtNombre = (EditText) rootView.findViewById(R.id.nombrePersonalActualizar);
            final EditText txtCellphone = (EditText) rootView.findViewById(R.id.cellphoneActualizar);
            final EditText txtEmail = (EditText) rootView.findViewById(R.id.emailActualizar);


            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.get(context, ip + "/user/" + id, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONObject user = null;
                    try {
                        user = response.getJSONObject("user");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    try {
                        txtNombre.setText(user.getString("name"));
                        JSONObject mail = user.getJSONObject("email");
                        txtEmail.setText(mail.getString("address"));
                        txtCellphone.setText(user.getString("phone"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }


            });
        } else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public static boolean validarEmail(String email) {

        // Compiles the given regular expression into a pattern.
        Pattern pattern = Pattern.compile(emailValido);

        // Match the given input against this pattern
        Matcher matcher = pattern.matcher(email);
        return matcher.matches();

    }

    public void actualizarPerfil(View view){

        Internet i = new Internet();
        final View v = view;


        if(i.verificaConexion(getContext())) {

            System.out.println("Entro a actualizar perfil");

            SharedPreferences prefs = this.getActivity().getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
            String id = prefs.getString("userID", "sinID");

            EditText txtNombre = (EditText) rootView.findViewById(R.id.nombrePersonalActualizar);
            EditText txtCellphone = (EditText) rootView.findViewById(R.id.cellphoneActualizar);
            EditText txtEmail = (EditText) rootView.findViewById(R.id.emailActualizar);
            EditText oldPassword = (EditText) rootView.findViewById(R.id.passwordActual);
            EditText password = (EditText) rootView.findViewById(R.id.passwordNueva);

            if (validarEmail(txtEmail.getText().toString())) {


                JSONObject params = new JSONObject();
                StringEntity entity = null;
                try {
                    params.put("name", txtNombre.getText().toString());
                    params.put("email", txtEmail.getText().toString());
                    params.put("phone", txtCellphone.getText().toString());

                    if (!oldPassword.getText().equals("") && !password.getText().equals("")) {
                        params.put("oldPassword", oldPassword.getText().toString());
                        params.put("password", password.getText().toString());
                    }

                    entity = new StringEntity(params.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }

                Context context = this.getActivity().getApplicationContext();

                AsyncHttpClient client = new AsyncHttpClient();
                client.addHeader("Authorization", token);
                client.put(context, ip + "/user/" + id, entity, "application/json", new JsonHttpResponseHandler() {

                    @Override
                    public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                        // If the response is JSONObject instead of expected JSONArray

                        Object msj = null;
                        try {
                            msj = response.get("message");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }

                        //Response
                        Snackbar.make(v, msj.toString(), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();

                    }

                    @Override
                    public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                        Snackbar.make(v, "No se pudo actualizar el perfil", Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }


                });
            }else {
                Snackbar.make(v, this.getString(R.string.correInvalidoException), Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        } else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }


    }

}
