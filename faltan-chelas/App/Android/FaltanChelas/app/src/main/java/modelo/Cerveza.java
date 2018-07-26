package modelo;

import android.os.Parcelable;

import java.io.Serializable;

/**
 * Created by gargui3 on 18/06/16.
 */
public class Cerveza implements Serializable{

    private String marca;
    //Precio total pedido o pack
    private String precio;
    //Cantidad de chelas por pack
    private String cantidad;
    //Cantidad de packs pedidos
    private int pack;

    public Cerveza(){

    }

    public Cerveza(String marca, String precio, String cantidad){
        this.marca = marca;
        this.precio = precio;
        this.cantidad = cantidad;
    }

    public int getPack() {
        return pack;
    }

    public void setPack(int pack) {
        this.pack = pack;
    }

    public String getMarca() {
        return marca;
    }

    public void setMarca(String marca) {
        this.marca = marca;
    }

    public String getPrecio() {
        return precio;
    }

    public void setPrecio(String precio) {
        this.precio = precio;
    }

    public String getCantidad() {
        return cantidad;
    }

    public void setCantidad(String cantidad) {
        this.cantidad = cantidad;
    }
}
