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
import android.widget.AbsListView;
import android.widget.ArrayAdapter;
import android.widget.ListView;

import com.example.gargui3.faltanchelas.Internet;
import com.example.gargui3.faltanchelas.R;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.ArrayList;

import Adaptadores.AdaptadorChelas;
import Adaptadores.AdaptadorHistorial;
import Adaptadores.AdaptadorPedido;
import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;
import modelo.Historial;

public class fragment_historial extends Fragment implements AbsListView.OnScrollListener {

    private ViewGroup rootView;
    private String ip;
    private String token;
    private String user_id;
    private String rol;
    private ArrayList<Historial> datos = new ArrayList<Historial>();
    private Historial[] mDatos = null;
    private int page = 1;

    public fragment_historial(){

    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        rootView = (ViewGroup) inflater.inflate(R.layout.fragment_historial, container, false);

        SharedPreferences prefs = this.getActivity().getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        this.ip = this.getString(R.string.ipaddress);
        this.token = prefs.getString("token", "sintoken");
        this.user_id = prefs.getString("userID", "sinUser");
        this.rol = prefs.getString("rol", "sinRol");

        getHistorial(page);

        return rootView;
    }

    public void createList(){
        AdaptadorHistorial adaptador =
                new AdaptadorHistorial(this.getContext(), mDatos);

        ListView lstOpciones = (ListView)rootView.findViewById(R.id.listaHistorial);

        lstOpciones.setAdapter(adaptador);

        lstOpciones.setOnScrollListener(this);
    }

    public void getHistorial(int page){
        Internet i = new Internet();
        final View v = this.getView();

        if(i.verificaConexion(getContext())) {


            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                if(rol.equals("user"))
                    params.put("user_id", this.user_id);
                else
                    params.put("vendor_id", this.user_id);
                params.put("page", page);
                params.put("limit", 20);
                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.post(context, ip + "/orders/byFilters", entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONObject orders;
                    JSONArray historial = null;
                    try {
                        orders = response.getJSONObject("orders");
                        historial = orders.getJSONArray("docs");
                        for(int i=0; i<historial.length(); i++){
                            Historial h = new Historial();
                            JSONObject order = historial.getJSONObject(i);
                            h.setNumVenta("" + order.getInt("order_id"));
                            h.setFecha(order.getString("date"));
                            h.setDomicilioEntrega(order.getJSONObject("destiny").getString("denomination"));
                            h.setTotal(order.getDouble("total"));
                            datos.add(h);
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    int tam = 0;
                    if(mDatos != null) {
                        tam = mDatos.length;
                        mDatos = new Historial[mDatos.length + historial.length()];
                    }else{
                        mDatos = new Historial[historial.length()];
                    }
                    for(int i=tam; i<datos.size(); i++){
                        Historial h = new Historial();
                        h.setNumVenta(datos.get(i).getNumVenta());
                        h.setFecha(datos.get(i).getFecha());
                        h.setDomicilioEntrega(datos.get(i).getDomicilioEntrega());
                        h.setTotal(datos.get(i).getTotal());
                        mDatos[i] = h;
                    }
                    if((historial != null ? historial.length() : 0) >0)
                        createList();

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    System.out.println(error.toString());
                }


            });
        } else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    @Override
    public void onScroll(AbsListView view,
                         int firstVisible, int visibleCount, int totalCount) {

        boolean loadMore = /* maybe add a padding */
                firstVisible + visibleCount >= totalCount;

        if(loadMore) {
            page += 1;
            System.out.println("Entro a mas datos");
            getHistorial(page);
        }
    }

    @Override
    public void onScrollStateChanged(AbsListView v, int s) {

    }
}
