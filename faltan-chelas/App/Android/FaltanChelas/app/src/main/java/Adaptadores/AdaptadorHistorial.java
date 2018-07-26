package Adaptadores;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.example.gargui3.faltanchelas.R;

import java.io.UnsupportedEncodingException;

import modelo.Cerveza;
import modelo.Historial;

/**
 * Created by gargui3 on 12/07/16.
 */
public class AdaptadorHistorial  extends ArrayAdapter<Historial> {

    Historial[] datos;

    public AdaptadorHistorial(Context context, Historial[] datos) {
        super(context, R.layout.fragment_historial, datos);
        this.datos = datos;
    }

    public View getView(final int position, final View convertView, ViewGroup parent) {

        final LayoutInflater inflater = LayoutInflater.from(getContext());
        final View item = inflater.inflate(R.layout.lista_historial, null);

        TextView lblTitulo = (TextView) item.findViewById(R.id.tituloVenta);
        lblTitulo.setText("#" + datos[position].getNumVenta() + " | " + datos[position].getFecha());

        String domicilio = "";
        try {
            domicilio = new String(datos[position].getDomicilioEntrega().getBytes("ISO-8859-1"), "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        TextView lblDomicilio = (TextView)item.findViewById(R.id.direccionEntrega);
        lblDomicilio.setText(domicilio);

        TextView lblTotal = (TextView)item.findViewById(R.id.totalVenta);
        lblTotal.setText("$" + datos[position].getTotal());

        return(item);
    }
}