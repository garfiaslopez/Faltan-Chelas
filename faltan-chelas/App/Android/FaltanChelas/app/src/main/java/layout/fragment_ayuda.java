package layout;

import android.content.Context;
import android.content.Intent;
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

import com.example.gargui3.faltanchelas.AccessActivity;
import com.example.gargui3.faltanchelas.Internet;
import com.example.gargui3.faltanchelas.R;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;

public class fragment_ayuda extends Fragment {

    String ip;
    String token;

    public fragment_ayuda(){

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        ViewGroup rootView = (ViewGroup) inflater.inflate(R.layout.fragment_ayuda, container, false);

        SharedPreferences prefs = this.getActivity().getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        this.ip = this.getString(R.string.ipaddress);
        this.token = prefs.getString("token", "sintoken");

        Button btnEnviar = (Button) rootView.findViewById(R.id.btnenviarPregunta);
        btnEnviar.setOnClickListener(new View.OnClickListener(){
            public void onClick(View v){
                enviarPregunta(v);
            }
        });

        return rootView;
    }

    public void enviarPregunta(View view){

        Internet i = new Internet();
        final View v = view;

        if(i.verificaConexion(getContext())) {

            System.out.println("Entro a enviar ayuda");

            SharedPreferences prefs = this.getActivity().getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
            String id = prefs.getString("userID", "sinID");

            final EditText subject = (EditText) getView().findViewById(R.id.subject);
            final EditText description = (EditText) getView().findViewById(R.id.description);

            if (!subject.getText().toString().equals("") && !description.getText().toString().equals("")) {

                JSONObject params = new JSONObject();
                StringEntity entity = null;
                try {
                    params.put("subject", subject.getText().toString());
                    params.put("description", description.getText().toString());
                    params.put("user_id", id);
                    entity = new StringEntity(params.toString());
                } catch (JSONException e) {
                    e.printStackTrace();
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }

                Context context = this.getActivity().getApplicationContext();

                AsyncHttpClient client = new AsyncHttpClient();
                client.addHeader("Authorization", token);
                client.post(context, ip + "/help", entity, "application/json", new JsonHttpResponseHandler() {

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
                        subject.setText("");
                        description.setText("");
                        Snackbar.make(v, msj.toString(), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();

                    }

                    @Override
                    public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                        System.out.println(error.getLocalizedMessage());
                        System.out.println(response.toString());
                        System.out.println(statusCode);
                    }


                });
            } else {
                Snackbar.make(v, this.getString(R.string.camposVaciosException), Snackbar.LENGTH_LONG)
                        .setAction("Action", null).show();
            }
        }else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }


    }

}
