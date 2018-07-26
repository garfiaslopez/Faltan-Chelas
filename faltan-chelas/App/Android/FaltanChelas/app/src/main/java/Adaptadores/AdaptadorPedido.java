package Adaptadores;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;
import com.example.gargui3.faltanchelas.R;

import modelo.Cerveza;

/**
 * Created by gargui3 on 19/06/16.
 */
public class AdaptadorPedido extends ArrayAdapter<Cerveza> {

    Cerveza[] datos;

    public AdaptadorPedido(Context context, Cerveza[] datos) {
        super(context, R.layout.activity_resumen, datos);
        this.datos = datos;
    }

    public View getView(final int position, final View convertView, ViewGroup parent) {

        final LayoutInflater inflater = LayoutInflater.from(getContext());
        final View item = inflater.inflate(R.layout.lista_pedido, null);

        TextView lblTitulo = (TextView) item.findViewById(R.id.marcaChelaPedida);
        lblTitulo.setText(datos[position].getMarca());

        TextView lblNumber = (TextView)item.findViewById(R.id.packNumber);
        lblNumber.setText(datos[position].getCantidad());

        TextView lblSubtitulo = (TextView)item.findViewById(R.id.precioChelaTotalPedido);
        lblSubtitulo.setText("$" + datos[position].getPrecio());

        return(item);
    }
}
