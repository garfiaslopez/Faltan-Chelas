package com.example.gargui3.faltanchelas;

import android.Manifest;
import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.location.Address;
import android.location.Criteria;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.Uri;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;

import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PolylineOptions;
import com.google.maps.android.PolyUtil;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.List;

import cz.msebera.android.httpclient.Header;

public class Encamino extends AppCompatActivity implements LocationListener {

    private SocketIO socket;
    private String rol;
    private JSONObject orderActual;
    private String phone;
    private String vendor_id;
    private String order_id;
    private Boolean permisos = true;

    //Mapa
    private LocationManager locManager;
    private MapView mMapView;
    private GoogleMap mGoogleMap;
    private GoogleMap mapa;
    private double lat = 0.0;
    private  double lng = 0.0;
    private double latDestino = 0.0;
    private double lngDestino = 0.0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {

        this.socket = SocketIO.getInstance();
        if(!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this);
        }else {
            this.socket.setActivity(this);
        }
        this.socket.backReturn("Encamino");
        this.orderActual = this.socket.getOrderActual();

        SharedPreferences prefs = this.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        this.rol = prefs.getString("rol", "sinrol");

        SharedPreferences.Editor editor = prefs.edit();
        editor.putString("isCalifico", "false");
        editor.commit();
        socket.setIsCalifico("false");

        String name = "";
        String address = "";

        TextView btnEntregado;

        super.onCreate(savedInstanceState);
        if (rol.equals("user")){
            try {
                JSONObject vendor = this.orderActual.getJSONObject("vendor_id");
                name = vendor.getString("name");
                String phone = vendor.getString("phone");
                address = vendor.getString("marketname");
                this.phone = phone;
            } catch (JSONException e) {
                e.printStackTrace();
            }
            setContentView(R.layout.activity_encamino);
        }else if(rol.equals("vendor")) {
            try {
                order_id = this.orderActual.getString("_id");
                JSONObject vendor = this.orderActual.getJSONObject("vendor_id");
                vendor_id = vendor.getString("_id");
                JSONObject user = this.orderActual.getJSONObject("user_id");
                name = user.getString("name");
                String phone = user.getString("phone");
                JSONObject loc = this.orderActual.getJSONObject("destiny");
                address = loc.getString("denomination");
                JSONArray cord = loc.getJSONArray("cord");
                this.lngDestino = cord.getDouble(0);
                this.latDestino = cord.getDouble(1);
                this.phone = phone;
            } catch (JSONException e) {
                e.printStackTrace();
            }
            setContentView(R.layout.activity_encamino_vendor);

            //inicializacion del mapa
            mMapView = (MapView) this.findViewById(R.id.map);
            mMapView.onCreate(savedInstanceState);
            mMapView.onResume();
            try {
                MapsInitializer.initialize(this.getApplicationContext());
            } catch (Exception e) {
                e.printStackTrace();
            }
            mGoogleMap = mMapView.getMap();
            onMapReady(mGoogleMap);

            //Geolocalizacion al dar click en el boton
            FloatingActionButton btn = (FloatingActionButton) this.findViewById(R.id.getMyLocationEncamino);
            btn.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    getMyLocation(v);
                }
            });

            btnEntregado = (TextView) findViewById(R.id.entregado);
            btnEntregado.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    recibido();
                }
            });

        }

        TextView txtUsuario = (TextView) findViewById(R.id.nombreUsuarioEncamino);
        TextView txtTienda = (TextView) findViewById(R.id.tienda);

        txtUsuario.setText(name);
        txtTienda.setText(address);


    }

    @Override
    public void onRestart(){
        super.onRestart();
        this.socket.conectar(this.getString(R.string.ipaddress));
    }

    public Boolean obtenerPermiso(){
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.CALL_PHONE)
                != PackageManager.PERMISSION_GRANTED) {

            if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                    Manifest.permission.CALL_PHONE)) {



            } else {

                // No explanation needed, we can request the permission.

                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.CALL_PHONE},
                        1);


                // MY_PERMISSIONS_REQUEST_READ_CONTACTS is an
                // app-defined int constant. The callback method gets the
                // result of the request.
            }

        }
        return this.permisos;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String permissions[], int[] grantResults) {
        switch (requestCode) {
            case 1: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    // permission was granted, yay! Do the
                    // contacts-related task you need to do.

                } else {

                    // permission denied, boo! Disable the
                    // functionality that depends on this permission.
                }
                return;
            }

            // other 'case' lines to check for other
            // permissions this app might request
        }
    }

    public void mandarSms(View view){
        Intent sendIntent = new Intent(Intent.ACTION_VIEW);
        sendIntent.setData(Uri.parse("sms:" + this.phone));
        if(this.rol.equals("user"))
            sendIntent.putExtra("sms_body", "Donde vienes?");
        else if(this.rol.equals("vendor"))
            sendIntent.putExtra("sms_body", "Ya voy en camino");
        startActivity(sendIntent);
    }

    public void realizarLlamada(View view){
        if(obtenerPermiso()) {
            Intent sendIntent = new Intent(Intent.ACTION_CALL);
            sendIntent.setData(Uri.parse("tel:" + this.phone));
            startActivity(sendIntent);
        }else{
            Snackbar.make(view, "Necesitas aceptar el permiso para realizar llamadas", Snackbar.LENGTH_LONG)
                    .setAction("Action", null).show();
        }
    }

    public void getMyLocation(View view){
        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_COARSE_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {

            locManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);

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

    public void onMapReady(GoogleMap map) {

        this.mapa = map;

        if (ContextCompat.checkSelfPermission(this,
                Manifest.permission.ACCESS_COARSE_LOCATION)
                == PackageManager.PERMISSION_GRANTED) {

            locManager = (LocationManager) this.getSystemService(Context.LOCATION_SERVICE);

            Criteria criteria = new Criteria();
            criteria.setAccuracy(Criteria.ACCURACY_FINE);
            String provider = locManager.getBestProvider(criteria, true);

            locManager.requestLocationUpdates(provider, 1000, 1, this);

            Location lc = locManager.getLastKnownLocation(provider);


            if (lc != null) {

                onLocationChanged(lc);

                map.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(lat, lng), 10));

                trazarRuta(lat, lng, latDestino, lngDestino);

            }else {

                map.moveCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(19.416668, -99.116669), 10));

            }
        }

    }

    public void trazarRuta(double latO, double lngO, double latD, double lngD){
        Internet i = new Internet();

        if(i.verificaConexion(this)) {

            String url = "https://maps.googleapis.com/maps/api/directions/json?origin=" + latO + "," + lngO + "&destination=" + latD + "," + lngD;


            Context context = this.getApplicationContext();

            AsyncHttpClient client = new AsyncHttpClient();
            client.get(context, url, new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    JSONArray route = null;
                    try {
                        route = response.getJSONArray("routes");
                        JSONObject objRoute = route.getJSONObject(0);
                        JSONObject overview = objRoute.getJSONObject("overview_polyline");
                        String polylineString = overview.getString("points");
                        List<LatLng> decodedPoints = PolyUtil.decode(polylineString);
                        PolylineOptions options = new PolylineOptions();
                        options.width(6);
                        options.color(R.color.colorAccent);
                        options.addAll(decodedPoints);

                        mapa.addPolyline(options);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }

                }


            });
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

    public void recibido(){
        System.out.println("Entro a entregar");
        this.socket.deliverOrder(order_id, vendor_id);
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
