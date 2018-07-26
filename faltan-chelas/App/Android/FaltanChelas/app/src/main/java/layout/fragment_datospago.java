package layout;

import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;

import com.example.gargui3.faltanchelas.Internet;
import com.example.gargui3.faltanchelas.MainActivity;
import com.example.gargui3.faltanchelas.R;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;
import io.conekta.conektasdk.Card;
import io.conekta.conektasdk.Conekta;
import io.conekta.conektasdk.Token;

public class fragment_datospago extends Fragment {

    public fragment_datospago(){

    }

    ViewGroup rootView;
    private String ip;
    private String token;
    private JSONArray tarjetas;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        this.rootView = (ViewGroup) inflater.inflate(R.layout.fragment_datospago, container, false);

        SharedPreferences prefs = this.getActivity().getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        this.ip = this.getString(R.string.ipaddress);
        this.token = prefs.getString("token", "sintoken");

        getTarjetas();


        Button btn = (Button) rootView.findViewById(R.id.modalTarjeta);
        btn.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                agregarTarjeta(v);
            }
        });

        return rootView;
    }

    public void createList(){
        final String[] datos = new String[tarjetas.length()];

        for(int i = 0; i < tarjetas.length(); i++)
        {
            try {
                JSONObject tarjeta = tarjetas.getJSONObject(i);
                datos[i] = "•••• •••• •••• " + tarjeta.getString("last4");
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }

        ArrayAdapter<String> adaptador =
                new ArrayAdapter<String>(this.getActivity(), android.R.layout.simple_list_item_1, datos);

        ListView lstOpciones = (ListView)rootView.findViewById(R.id.listaMisTarjetas);

        lstOpciones.setAdapter(adaptador);

        lstOpciones.setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() {

            public boolean onItemLongClick(AdapterView<?> arg0, View v,
                                           final int index, long arg3) {

                new AlertDialog.Builder(getActivity())
                        .setTitle("Eliminar")
                        .setMessage("Deseas eliminar este elemento?")
                        .setIcon(android.R.drawable.ic_dialog_alert)
                        .setPositiveButton("Si", new DialogInterface.OnClickListener() {

                            public void onClick(DialogInterface dialog, int whichButton) {
                                try {
                                    JSONObject card = tarjetas.getJSONObject(index);
                                    String idCard = card.getString("id");
                                    eliminarTarjeta(idCard);
                                } catch (JSONException e) {
                                    e.printStackTrace();
                                }
                            }
                        })
                        .setNegativeButton("No", null).show();
                return false;
            }
        });
    }

    public void eliminarTarjeta(String idCard){
        Internet i = new Internet();

        if(i.verificaConexion(this.getContext())) {

            SharedPreferences prefs = this.getActivity().getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
            String id = prefs.getString("userID", "sinID");


            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.delete(context, ip + "/conekta/card/" + id + "/" + idCard, new JsonHttpResponseHandler() {

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

                        getTarjetas();
                        Snackbar.make(getView(), "Eliminado Correctamente", Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();

                    } else {
                        Snackbar.make(getView(), msj.toString(), Snackbar.LENGTH_LONG)
                                .setAction("Action", null).show();
                    }

                }

            });
        }else{
            Snackbar.make(getView(), this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void getTarjetas(){
        Internet i = new Internet();
        final View v = this.getView();

        if(i.verificaConexion(getContext())) {

            SharedPreferences prefs = this.getActivity().getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
            String id = prefs.getString("userID", "sinID");

            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.get(context, ip + "/conekta/cards/" + id, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONArray cards = null;
                    try {
                        cards = response.getJSONArray("cards");
                        tarjetas = cards;
                        System.out.println("Cantidad de tarjetas: " + cards.length());
                        createList();
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

    public void crearTarjeta(String name, String numTarjeta, String CVC, String mes, String ano, final Dialog d, final View view){
        Conekta.setPublicKey(this.getString(R.string.conektaPublicKey)); //Set public key
        Conekta.setApiVersion("1.0.0"); //Set api version (optional)
        Conekta.collectDevice(this.getActivity()); //Collect device

        Card card = new Card(name, numTarjeta, CVC, mes, ano);
        Token token = new Token(this.getActivity());

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

        if(i.verificaConexion(this.getContext())) {

            SharedPreferences prefs = this.getActivity().getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
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

            Context context = this.getActivity().getApplicationContext();

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

}
