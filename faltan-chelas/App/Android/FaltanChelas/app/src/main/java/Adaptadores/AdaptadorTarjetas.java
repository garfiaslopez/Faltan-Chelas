package Adaptadores;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.example.gargui3.faltanchelas.R;
import com.example.gargui3.faltanchelas.Resumen;

import modelo.Tarjeta;

/**
 * Created by gargui3 on 19/06/16.
 */
public class AdaptadorTarjetas extends ArrayAdapter<Tarjeta> {

    Tarjeta[] datos;
    Resumen r;

    public AdaptadorTarjetas(Context context, Tarjeta[] datos, Resumen r) {
        super(context, R.layout.activity_resumen, datos);
        this.datos = datos;
        this.r = r;
    }

    public View getView(final int position, final View convertView, ViewGroup parent) {

        final LayoutInflater inflater = LayoutInflater.from(getContext());
        final View item = inflater.inflate(R.layout.lista_tarjetas, null);

        TextView lblNumTarjeta = (TextView) item.findViewById(R.id.numeroTarjeta);
        String numTarjeta = datos[position].getNumTarjeta();
        lblNumTarjeta.setText("   •••• •••• •••• " + numTarjeta);

        ImageView imgTarjeta = (ImageView)item.findViewById(R.id.tipo);
        String tipo = datos[position].getTipoTarjeta();

        if(tipo.equals("MC"))
            imgTarjeta.setImageResource(R.mipmap.mastercard);
        else if(tipo.equals("VISA"))
            imgTarjeta.setImageResource(R.mipmap.visa);
        else if(tipo.equals("AMERICAN_EXPRESS"))
            imgTarjeta.setImageResource(R.mipmap.amex);

        item.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                ImageView imgCorrect = (ImageView)item.findViewById(R.id.correctTarjeta);
                r.setTarjeta(datos[position], imgCorrect);
            }

        });

        return(item);
    }
}
