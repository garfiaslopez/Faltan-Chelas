package Adaptadores;

import android.content.Context;
import android.support.design.widget.Snackbar;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.example.gargui3.faltanchelas.MenuChelero;
import com.example.gargui3.faltanchelas.R;

import java.util.ArrayList;

import modelo.Cerveza;
import modelo.Venta;

/**
 * Created by gargui3 on 19/06/16.
 */
public class AdaptadorChelas extends ArrayAdapter<Cerveza> {

    final Venta val = new Venta();
    Cerveza[] ventaTotal;
    Cerveza[] datos;
    MenuChelero m;

    public AdaptadorChelas(Context context, Cerveza[] datos, MenuChelero m) {
        super(context, R.layout.activity_menu_chelero, datos);
        this.datos = datos;
        this.ventaTotal = new Cerveza[datos.length];
        this.m = m;
    }

    public View getView(final int position, final View convertView, ViewGroup parent) {

        final LayoutInflater inflater = LayoutInflater.from(getContext());
        final View item = inflater.inflate(R.layout.lista_chelera, null);

        TextView lblTitulo = (TextView)item.findViewById(R.id.marcaChela);
        lblTitulo.setText(datos[position].getMarca());

        TextView lblSubtitulo = (TextView)item.findViewById(R.id.precioChela);
        lblSubtitulo.setText("$" + datos[position].getPrecio() + " el pack de " + datos[position].getCantidad());

        ImageView btnMas = (ImageView) item.findViewById(R.id.masChelas);

        ImageView btnMenos = (ImageView) item.findViewById(R.id.menosChelas);

        TextView txtCanti = (TextView) item.findViewById(R.id.cantidadChelas);
        txtCanti.setText("0");

        btnMas.setOnClickListener(new View.OnClickListener() {

            Cerveza c = new Cerveza();
            @Override
            public void onClick(View v) {
                int vendidas = val.getChelasPedidas() + Integer.parseInt(datos[position].getCantidad());
                c.setPack(Integer.parseInt(datos[position].getCantidad()));
                int total = val.getMaximoChelas();
                if (vendidas <= total) {
                    ImageView im = (ImageView) item.findViewById(R.id.menosChelas);
                    im.setVisibility(View.VISIBLE);
                    TextView txtCant = (TextView) item.findViewById(R.id.cantidadChelas);
                    int cant = Integer.parseInt(txtCant.getText().toString());
                    int cantActual = cant + 1;
                    //Datos chela
                    c.setMarca(datos[position].getMarca());
                    System.out.println( position + "Marcar agregada: " + datos[position].getMarca());
                    double precioTotal = Double.parseDouble(datos[position].getPrecio()) * cantActual;
                    c.setPrecio("" + precioTotal);
                    c.setCantidad("" + cantActual);

                    ventaTotal[position] = c;

                    txtCant.setText("" + cantActual);
                    val.setChelasPedidas(Integer.parseInt(datos[position].getCantidad()));
                    val.setSubtotal(Double.parseDouble(datos[position].getPrecio()));

                    m.calcular(val, ventaTotal);

                } else {
                    Snackbar.make(v, getContext().getString(R.string.maximoVendidoException), Snackbar.LENGTH_LONG)
                            .setAction("Action", null).show();
                }
            }
        });

        btnMenos.setOnClickListener(new View.OnClickListener() {
            Cerveza c = new Cerveza();
            @Override
            public void onClick(View v) {
                int vendidas = val.getChelasPedidas();
                if (vendidas > 0) {
                    TextView txtCant = (TextView) item.findViewById(R.id.cantidadChelas);
                    int cant = Integer.parseInt(txtCant.getText().toString());
                    int cantActual = cant - 1;
                    txtCant.setText("" + cantActual);
                    val.setChelasPedidas(-(Integer.parseInt(datos[position].getCantidad())));
                    val.setSubtotal(-(Double.parseDouble(datos[position].getPrecio())));
                    ventaTotal[position] = c;
                    if (cantActual == 0) {
                        ImageView im = (ImageView) item.findViewById(R.id.menosChelas);
                        im.setVisibility(View.INVISIBLE);
                        ventaTotal[position] = null;
                    }

                    c.setMarca(datos[position].getMarca());
                    double precioTotal = Double.parseDouble(datos[position].getPrecio()) * cantActual;
                    c.setPrecio("" + precioTotal);
                    c.setCantidad("" + cantActual);

                    m.calcular(val, ventaTotal);

                }
            }
        });

        return(item);
    }
}
