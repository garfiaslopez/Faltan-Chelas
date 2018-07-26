package com.example.gargui3.faltanchelas;

import android.Manifest;
import android.app.Activity;
import android.app.ActivityManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.support.design.widget.Snackbar;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.support.design.widget.NavigationView;
import android.support.v4.app.FragmentActivity;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.google.android.gms.appindexing.Action;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.common.api.GoogleApiClient;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.urbanairship.UAirship;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.util.List;
import java.util.Stack;

import cz.msebera.android.httpclient.Header;
import cz.msebera.android.httpclient.entity.StringEntity;
import layout.fragment_ayuda;
import layout.fragment_datospago;
import layout.fragment_historial;
import layout.fragment_pedir;
import layout.fragment_perfil;


public class MainActivity extends AppCompatActivity
        implements NavigationView.OnNavigationItemSelectedListener {

    //Pila para el manejo de los items del menu en retroceso
    Stack<MenuItem> listaMenu = new Stack<MenuItem>();
    //Pila para el manejo de los id menu para el retroceso
    Stack<Integer> indices = new Stack<Integer>();
    private String rol;
    private Boolean firstUse = true;
    private SocketIO socket;
    /**
     * ATTENTION: This was auto-generated to implement the App Indexing API.
     * See https://g.co/AppIndexing/AndroidStudio for more information.
     */
    private GoogleApiClient client;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        SharedPreferences prefs = this.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);

        System.out.println("Entro main");

        sendChannelId(UAirship.shared().getPushManager().getChannelId());

        rol = prefs.getString("rol", "sinrol");

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(
                this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
        drawer.setDrawerListener(toggle);
        toggle.syncState();

        NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
        navigationView.setNavigationItemSelectedListener(this);

        this.socket = SocketIO.getInstance();
        if(!this.socket.getActivo()) {
            this.socket.inicializar(this.getString(R.string.ipaddress), this);
        }else {
            this.socket.setActivity(this);
            this.socket.conectar(this.getString(R.string.ipaddress));
        }

        //Inicializando primer fragmento
        Fragment f = new fragment_pedir();

        getSupportFragmentManager().beginTransaction()
                .replace(R.id.content_frame, f)
                .addToBackStack("Principal")
                .commit();

        if (rol.equals("vendor")) {
            navigationView.getMenu().getItem(0).setTitle("Esperar pedidos");
            navigationView.getMenu().getItem(3).setVisible(false);
        }

        navigationView.getMenu().getItem(0).setChecked(true);
        getSupportActionBar().setTitle(navigationView.getMenu().getItem(0).getTitle());
        indices.push(0);
        listaMenu.push(navigationView.getMenu().getItem(0));
        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        client = new GoogleApiClient.Builder(this).addApi(AppIndex.API).build();
    }

    @Override
    public void onRestart(){
        super.onRestart();
        this.socket.conectar(this.getString(R.string.ipaddress));
    }

    public void sendChannelId(String channel){

        Internet i = new Internet();
        System.out.println("Channel: " + channel);

        if(i.verificaConexion(this)) {

            SharedPreferences prefs = this.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
            String id = prefs.getString("userID", "sinID");
            String token = prefs.getString("token", "sintoken");
            final String rol = prefs.getString("rol", "sinrol");

            JSONObject params = new JSONObject();
            StringEntity entity = null;
            try {
                params.put("push_id", channel);
                entity = new StringEntity(params.toString());
            } catch (JSONException e) {
                e.printStackTrace();
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }

            Context context = this.getApplicationContext();

            String ip = getString(R.string.ipaddress);

            AsyncHttpClient client = new AsyncHttpClient();
            client.addHeader("Authorization", token);
            client.put(context, ip + "/user/" + id, entity, "application/json", new JsonHttpResponseHandler() {

                @Override
                public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                    // If the response is JSONObject instead of expected JSONArray
                    UAirship.shared().getPushManager().editTags()
                            .addTag(rol)
                            .addTag("Android")
                            .apply();
                }

                @Override
                public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {
                    System.out.println(error.getLocalizedMessage());
                    System.out.println(response.toString());
                    System.out.println(statusCode);
                }


            });

        }else {
            System.out.println("Sin internet");
        }

    }

    @Override
    public void onBackPressed() {
        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        if (drawer.isDrawerOpen(GravityCompat.START)) {
            drawer.closeDrawer(GravityCompat.START);
        } else if (getSupportFragmentManager().getBackStackEntryCount() > 1) {
            getSupportFragmentManager().popBackStack();
            NavigationView navigationView = (NavigationView) findViewById(R.id.nav_view);
            listaMenu.pop();
            indices.pop();
            navigationView.getMenu().getItem(indices.peek()).setChecked(true);
            getSupportActionBar().setTitle(listaMenu.peek().getTitle());
            System.out.println("entro a mas 0");
        } else {
            System.out.println("entro a menos 0");
            this.finish();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        TextView tUser = (TextView) findViewById(R.id.nombreUsuario);
        SharedPreferences prefs = getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
        tUser.setText(prefs.getString("username", "usuario"));
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement

        return super.onOptionsItemSelected(item);
    }

    @Override
    public boolean onNavigationItemSelected(MenuItem item) {
        // Handle navigation view item clicks here.
        boolean fragmentTransaction = false;
        Fragment fragment = null;
        int idd = 0;

        switch (item.getItemId()) {
            case R.id.pedir:
                fragment = new fragment_pedir();
                fragmentTransaction = true;
                idd = 0;
                break;
            case R.id.historial:
                fragment = new fragment_historial();
                fragmentTransaction = true;
                idd = 1;
                break;
            case R.id.perfil:
                fragment = new fragment_perfil();
                fragmentTransaction = true;
                idd = 2;
                break;
            case R.id.datosPago:
                fragment = new fragment_datospago();
                fragmentTransaction = true;
                idd = 3;
                break;
            case R.id.ayuda:
                fragment = new fragment_ayuda();
                fragmentTransaction = true;
                idd = 4;
                break;
        }

        if (fragmentTransaction) {

            if (!firstUse) {
                getSupportFragmentManager().popBackStack();
                listaMenu.pop();
                indices.pop();
            }

            firstUse = false;

            getSupportFragmentManager().beginTransaction()
                    .replace(R.id.content_frame, fragment)
                    .addToBackStack(item.getItemId() + item.getTitle().toString())
                    .commit();

            listaMenu.push(item);
            indices.push(idd);

            item.setChecked(true);
            getSupportActionBar().setTitle(item.getTitle());

        } else {

            SharedPreferences prefs = getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putString("token", "sintoken");
            editor.commit();

            this.socket.isEnded();

            if(rol.equals("vendor")) {

                Internet i = new Internet();

                if (i.verificaConexion(this)) {


                    JSONObject params = new JSONObject();
                    StringEntity entity = null;
                    try {
                        params.put("available", false);

                        entity = new StringEntity(params.toString());
                    } catch (JSONException e) {
                        e.printStackTrace();
                    } catch (UnsupportedEncodingException e) {
                        e.printStackTrace();
                    }

                    Context context = this.getApplicationContext();

                    SharedPreferences prefs2 = this.getSharedPreferences("DatosChelas", Context.MODE_PRIVATE);
                    String token = prefs2.getString("token", "sintoken");
                    String vendor_id = prefs2.getString("userID", "sinID");
                    String ip = this.getString(R.string.ipaddress);

                    AsyncHttpClient client = new AsyncHttpClient();
                    client.addHeader("Authorization", token);
                    client.put(context, ip + "/user/" + vendor_id, entity, "application/json", new JsonHttpResponseHandler() {

                        @Override
                        public void onSuccess(int statusCode, Header[] headers, JSONObject response) {
                            // If the response is JSONObject instead of expected JSONArray

                        }

                        @Override
                        public void onFailure(int statusCode, Header[] headers, Throwable error, JSONObject response) {

                        }


                    });
                }
            }

            Intent intent = new Intent(this, AccessActivity.class);
            this.finish();
            startActivity(intent);

        }

        DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
        drawer.closeDrawer(GravityCompat.START);
        return true;
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
    public void onStart() {
        super.onStart();

        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        client.connect();
        Action viewAction = Action.newAction(
                Action.TYPE_VIEW, // TODO: choose an action type.
                "Main Page", // TODO: Define a title for the content shown.
                // TODO: If you have web page content that matches this app activity's content,
                // make sure this auto-generated web page URL is correct.
                // Otherwise, set the URL to null.
                Uri.parse("http://host/path"),
                // TODO: Make sure this auto-generated app deep link URI is correct.
                Uri.parse("android-app://com.faltanchelas/http/host/path")
        );
        AppIndex.AppIndexApi.start(client, viewAction);
    }

    @Override
    public void onStop() {
        super.onStop();

        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        /*Action viewAction = Action.newAction(
                Action.TYPE_VIEW, // TODO: choose an action type.
                "Main Page", // TODO: Define a title for the content shown.
                // TODO: If you have web page content that matches this app activity's content,
                // make sure this auto-generated web page URL is correct.
                // Otherwise, set the URL to null.
                Uri.parse("http://host/path"),
                // TODO: Make sure this auto-generated app deep link URI is correct.
                Uri.parse("android-app://com.example.gargui3.faltanchelas/http/host/path")
        );
        AppIndex.AppIndexApi.end(client, viewAction);
        client.disconnect();*/
        if(!isForeground(this, "com.faltanchelas"))
            this.socket.isEnded();
    }
}
