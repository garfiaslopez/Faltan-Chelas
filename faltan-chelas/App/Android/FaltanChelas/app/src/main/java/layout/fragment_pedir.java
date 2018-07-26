package layout;

import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Criteria;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AlertDialog;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.example.gargui3.faltanchelas.Internet;
import com.example.gargui3.faltanchelas.MainActivity;
import com.example.gargui3.faltanchelas.MenuChelero;
import com.example.gargui3.faltanchelas.R;
import com.example.gargui3.faltanchelas.SocketIO;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;

public class fragment_pedir extends Fragment implements LocationListener {

    private LocationManager locManager;
    private MapView mMapView;
    private GoogleMap mGoogleMap;
    private ViewGroup rootView;
    private double lat = 19.416668;
    private double lng = -99.116669;
    private String rol;
    private GoogleMap mapa;
    private AutoCompleteTextView direccionEdit;
    private String direccionEnvio;
    private SocketIO socket;

    private static final String TAG = "Error";
    private static final String PLACES_API_BASE = "https://maps.googleapis.com/maps/api/place";
    private static final String TYPE_AUTOCOMPLETE = "/autocomplete";
    private static final String OUT_JSON = "/json";
    private static final String API_KEY = "AIzaSyApcrOP31ML7ux0U_NdTNM049zoIQ9ZZTc";

    private String token;
    private String ip;
    private Boolean returnApp = false;
    private String vendor_id;
    private Switch s;
    private Boolean vendorsDisponibles = true;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        //Recuperar rol de usuario
        SharedPreferences prefs = this.getActivity().getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        this.rol = prefs.getString("rol", "sinrol");
        this.token = prefs.getString("token", "sintoken");
        this.ip = this.getString(R.string.ipaddress);

        // Iniciar Socket
        this.socket = SocketIO.getInstance();
        if(!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this.getActivity());
        }else {
            this.returnApp = true;
            this.socket.setActivity(this.getActivity());
        }

        //Inicializar configuracion
        configuration();

        //Iniciar vista dependiendo el usuario
        if(rol.equals("user")){
            rootView = (ViewGroup) inflater.inflate(R.layout.fragment_pedir, container, false);
            Button btnEnviar = (Button) rootView.findViewById(R.id.btncontinuarPedido);
            btnEnviar.setOnClickListener(new View.OnClickListener() {
                public void onClick(View v) {
                    seleccionPedido(v);
                }
            });
            //inicializacion del mapa
            mMapView = (MapView) rootView.findViewById(R.id.map);
            mMapView.onCreate(savedInstanceState);
            mMapView.onResume();
            try {
                MapsInitializer.initialize(getActivity().getApplicationContext());
            } catch (Exception e) {
                e.printStackTrace();
            }
            mGoogleMap = mMapView.getMap();
            onMapReady(mGoogleMap);

            //Geolocalizacion al dar click en el boton
            FloatingActionButton btn = (FloatingActionButton) rootView.findViewById(R.id.getMyLocation);
            btn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    getMyLocation(v);
                }
            });

            //Google places
            direccionEdit = (AutoCompleteTextView) rootView.findViewById(R.id.Direccion);
            final GooglePlacesAutocompleteAdapter adapterPlaces = new GooglePlacesAutocompleteAdapter(this.getContext(), R.layout.list_places);
            direccionEdit.setAdapter(adapterPlaces);
            direccionEdit.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    String place = (String) parent.getItemAtPosition(position);
                    Geocoder geocoder = new Geocoder(getContext());
                    try {
                        List<Address> lista = geocoder.getFromLocationName(place, 1);
                        if (lista.size() > 0) {
                            Address direccion = lista.get(0);
                            direccionEnvio = direccion.getAddressLine(0) + " " + direccion.getLocality() + " " + direccion.getCountryName();
                            setLocation(direccion.getLatitude(), direccion.getLongitude());
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    getVendors();
                }
            });
        }else if(rol.equals("vendor")){
            this.vendor_id = prefs.getString("userID", "sinID");
            rootView = (ViewGroup) inflater.inflate(R.layout.fragment_pedir_vendor, container, false);
            this.s = (Switch) rootView.findViewById(R.id.disponibilidad);
            this.s.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    updateChecked(s.isChecked());
                }
            });
            updateChecked(true);
            inicializarDatosVendor();
        }

        if(returnApp){
            //mensaje de error socket
            if(this.socket.getError()){
                System.out.println("Entro a error");
                this.socket.setError(false);
                new AlertDialog.Builder(getActivity())
                        .setTitle("Sin tienderos")
                        .setMessage(this.getString(R.string.errorSocketException))
                        .setIcon(android.R.drawable.ic_dialog_alert)
                        .setPositiveButton("OK", null).show();
            }

            //mensaje de no aceptado
            if(this.socket.getNotAccepted()){
                System.out.println("Entro a not accepted");
                this.socket.setNotAccepted(false);
                if(this.rol.equals("user")) {
                    new AlertDialog.Builder(getActivity())
                            .setTitle("Sin tienderos")
                            .setMessage(this.getString(R.string.notAcceptedSocketException))
                            .setIcon(android.R.drawable.ic_dialog_alert)
                            .setPositiveButton("OK", null).show();
                }else if(this.rol.equals("vendor")){
                    new AlertDialog.Builder(getActivity())
                            .setTitle("Sin tienderos")
                            .setMessage(this.getString(R.string.buyExpiredException))
                            .setIcon(android.R.drawable.ic_dialog_alert)
                            .setPositiveButton("OK", null).show();
                }
            }
        }

        return rootView;
    }

    public void updateChecked(final Boolean status){
        Internet i = new Internet();

        final View v = this.getView();

        if(i.verificaConexion(getContext())) {


            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                params.put("available", status);

                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.put(context, ip + "/user/" + this.vendor_id, entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    Snackbar.make(v, "No se pudo cambiar tu disponibilidad", Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }


            });
        } else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void inicializarDatosVendor(){
        final TextView txtServicios = (TextView) rootView.findViewById(R.id.serviciosDia);
        final TextView txtTotal = (TextView) rootView.findViewById(R.id.totalDia);

        Internet i = new Internet();

        if(i.verificaConexion(getContext())) {


            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                params.put("isTotals", true);
                params.put("dateFilter", "today");
                params.put("vendor_id", this.vendor_id);

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
                    JSONObject datos = null;
                    try {
                        txtServicios.setText("#" + response.getString("count"));
                        txtTotal.setText("$" + response.getString("total"));
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }


                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    System.out.println(error.toString());
                    Snackbar.make(rootView, "No se pudieron obtener los datos del dia", Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }


            });
        } else {
            Snackbar.make(rootView, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }


    }

    public void configuration(){

        Internet i = new Internet();
        final View v = this.getView();
        SharedPreferences prefs = this.getActivity().getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        final SharedPreferences.Editor editor = prefs.edit();

        if(i.verificaConexion(getContext())) {

            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.get(context, ip + "/config", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONArray config = null;
                    try {
                        config = response.getJSONArray("configs");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                    try {
                        for (int i = 0; i < config.length(); i++) {
                            JSONObject conf = config.getJSONObject(i);
                            if (conf.getString("denomination").equals("MAX_CHELAS")) {
                                editor.putString("max_chelas", conf.getString("parameter"));
                            } else if (conf.getString("denomination").equals("COSTO_ENVIO")) {
                                editor.putString("costo_envio", conf.getString("parameter"));
                            }
                        }
                        editor.commit();
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    System.out.println(error.getLocalizedMessage());
                    System.out.println(statusCode);
                }


            });
        } else {
            Snackbar.make(v, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void getMyLocation(View view){
        if (ContextCompat.checkSelfPermission(this.getActivity(),
                Manifest.permission.ACCESS_COARSE_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {

            locManager = (LocationManager) getActivity().getSystemService(Context.LOCATION_SERVICE);

            Criteria criteria = new Criteria();
            criteria.setAccuracy(Criteria.ACCURACY_FINE);
            String provider = locManager.getBestProvider(criteria, true);


            locManager.requestLocationUpdates(provider, 1000, 1, this);

            Location lc = locManager.getLastKnownLocation(provider);

            if (lc != null) {

                onLocationChanged(lc);

                mapa.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(lat, lng), 20));

            }
        }
    }

    public void setLocation(Double latitude, Double longitude){
        this.lat = latitude;
        this.lng = longitude;
        mapa.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(latitude, longitude), 20));
    }

    public void onMapReady(GoogleMap map) {

        final Geocoder geocoder = new Geocoder(this.getContext());
        map.setOnCameraChangeListener(new GoogleMap.OnCameraChangeListener() {

            @Override
            public void onCameraChange(CameraPosition cameraPosition) {
                try {
                    List<Address> lista = geocoder.getFromLocation(cameraPosition.target.latitude, cameraPosition.target.longitude, 1);
                    lat = cameraPosition.target.latitude;
                    lng = cameraPosition.target.longitude;
                    if (lista.size() > 0) {
                        Address direccion = lista.get(0);
                        direccionEdit.setText(direccion.getAddressLine(0) + " " + direccion.getLocality() + " " + direccion.getCountryName());
                        direccionEnvio = direccionEdit.getText().toString();
                        direccionEdit.dismissDropDown();
                        getVendors();
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });

        this.mapa = map;

        if (ContextCompat.checkSelfPermission(this.getActivity(),
                Manifest.permission.ACCESS_COARSE_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {

            locManager = (LocationManager) getActivity().getSystemService(Context.LOCATION_SERVICE);

            Criteria criteria = new Criteria();
            criteria.setAccuracy(Criteria.ACCURACY_FINE);
            String provider = locManager.getBestProvider(criteria, true);


            locManager.requestLocationUpdates(provider, 1000, 1, this);

            Location lc = locManager.getLastKnownLocation(provider);

            if (lc != null) {

                onLocationChanged(lc);

                map.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(lat, lng), 20));

                getVendors();

            }else{

                map.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(19.416668, -99.116669), 20));

                getVendors();

            }
        }else{

            map.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(19.416668, -99.116669), 20));

            getVendors();

        }

    }

    public void getVendors(){


        Internet i = new Internet();

        System.out.println("Entro a getVendors");

        if(i.verificaConexion(getContext())) {

            Context context = this.getActivity().getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.get(context, ip + "/users/byavailablevendors/bylocation/" + this.lat + "/" + this.lng, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONArray users = null;
                    System.out.println("Entro a pedir vendedores");
                    try {
                        users = response.getJSONArray("vendors");
                        if(users.length() > 0) {
                            System.out.println("Entro a users mas 0 " + users.length());
                            for (int i = 0; i < users.length(); i++) {
                                JSONObject user = users.getJSONObject(i);
                                JSONObject loc = user.getJSONObject("loc");
                                JSONArray cord = loc.getJSONArray("cord");
                                BitmapDescriptor icon = BitmapDescriptorFactory.fromResource(R.mipmap.markervendor);
                                LatLng pos = new LatLng(cord.getDouble(1), cord.getDouble(0));
                                mapa.addMarker(new MarkerOptions()
                                        .position(pos).title(user.getString("marketname")).icon(icon));
                                vendorsDisponibles = true;
                            }
                        }else{
                            System.out.println("entro a user menos 0");
                            vendorsDisponibles = false;
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    vendorsDisponibles = false;
                    Snackbar.make(rootView, "No hay vendedores disponibles", Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }

            });
        } else {
            Snackbar.make(rootView, this.getString(R.string.sinConexionException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }

    }

    public void seleccionPedido(View view) {
        if(this.vendorsDisponibles) {
            Intent in = new Intent(getActivity(), MenuChelero.class);
            in.putExtra("direccionEnvio", direccionEnvio);
            in.putExtra("latitude", lat);
            in.putExtra("longitude", lng);
            startActivity(in);
        }else{
            Snackbar.make(view, this.getString(R.string.notVendorsAvailableException), Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    @Override
    public void onLocationChanged(Location location) {
        this.lat = location.getLatitude();
        this.lng = location.getLongitude();
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {

    }

    @Override
    public void onProviderEnabled(String provider) {

    }

    @Override
    public void onProviderDisabled(String provider) {

    }

    public ArrayList<String> autocomplete (String input) {
        ArrayList<String> resultList = null;

        HttpURLConnection conn = null;
        StringBuilder jsonResults = new StringBuilder();

        try {
            StringBuilder sb = new StringBuilder(PLACES_API_BASE + TYPE_AUTOCOMPLETE + OUT_JSON);
            sb.append("?key=" + API_KEY);
            sb.append("&components=country:mx");
            sb.append("&input=" + URLEncoder.encode(input, "utf8"));

            URL url = new URL(sb.toString());
            conn = (HttpURLConnection) url.openConnection();
            InputStreamReader in = new InputStreamReader(conn.getInputStream());

            // Load the results into a StringBuilder
            int read;
            char[] buff = new char[1024];
            while ((read = in.read(buff)) != -1) {
                jsonResults.append(buff, 0, read);
            }
        } catch (MalformedURLException e) {
            Log.e(TAG, "Error processing Places API URL", e);
            return resultList;
        } catch (IOException e) {
            Log.e(TAG, "Error connecting to Places API", e);
            return resultList;
        } finally {
            if (conn != null) {
                conn.disconnect();
            }
        }

        try {
            // Log.d(TAG, jsonResults.toString());

            // Create a JSON object hierarchy from the results
            JSONObject jsonObj = new JSONObject(jsonResults.toString());
            JSONArray predsJsonArray = jsonObj.getJSONArray("predictions");

            // Extract the Place descriptions from the results
            resultList = new ArrayList<String>(predsJsonArray.length());
            for (int i = 0; i < predsJsonArray.length(); i++) {
                resultList.add(predsJsonArray.getJSONObject(i).getString("description"));
            }
        } catch (JSONException e) {
            Log.e(TAG, "Cannot process JSON results", e);
        }

        return resultList;
    }

    class GooglePlacesAutocompleteAdapter extends ArrayAdapter<String> implements Filterable {
        private ArrayList<String> resultList;
        public GooglePlacesAutocompleteAdapter(Context context, int textViewResourceId) {
            super(context, textViewResourceId);
        }
        @Override
        public int getCount() {
            return resultList.size();
        }
        @Override
        public String getItem(int index) {
            return resultList.get(index);
        }
        @Override
        public Filter getFilter() {
            Filter filter = new Filter() {
                @Override
                protected FilterResults performFiltering(CharSequence constraint) {
                    FilterResults filterResults = new FilterResults();
                    if (constraint != null) {
                        // Retrieve the autocomplete results.

                        System.out.println("Entro: " + constraint);

                        resultList = autocomplete(constraint.toString());
                        // Assign the data to the FilterResults
                        filterResults.values = resultList;
                        filterResults.count = resultList.size();
                        System.out.println("cantidad: " + resultList.size());
                    }
                    return filterResults;
                }
                @Override

                protected void publishResults(CharSequence constraint, FilterResults results) {
                    if (results != null && results.count > 0) {
                        notifyDataSetChanged();
                    } else {
                        notifyDataSetInvalidated();
                    }
                }

            };
            return filter;
        }

        @Override
        public View getView(int position, View convertView, ViewGroup parent) {

            //if (position != (resultList.size() - 1))
            final LayoutInflater inflater = LayoutInflater.from(getContext());
                View view = inflater.inflate(R.layout.list_places, null);
            /*else
                view = inflater.inflate(R.layout.autocomplete_google_logo, null);*/
            //}
            //else {
            //    view = convertView;
            //}

            if (position != (resultList.size())) {
                TextView autocompleteTextView = (TextView) view.findViewById(R.id.completePlaces);
                autocompleteTextView.setText(resultList.get(position));
            }
            /*else {
                ImageView imageView = (ImageView) view.findViewById(R.id.imageView);
                // not sure what to do <img draggable="false" class="emoji" alt="😀" src="https://s.w.org/images/core/emoji/72x72/1f600.png">
            }*/

            return view;
        }

    }

}


