package modelo;

import java.io.Serializable;

/**
 * Created by gargui3 on 19/06/16.
 */
public class Tarjeta implements Serializable {

    private String tipoTarjeta;
    //ultimos 4 digitos
    private String numTarjeta;
    private String token;

    public Tarjeta(){

    }

    public Tarjeta(String tipoTarjeta, String numTarjeta){
        this.tipoTarjeta = tipoTarjeta;
        this.numTarjeta = numTarjeta;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getTipoTarjeta() {
        return tipoTarjeta;
    }

    public void setTipoTarjeta(String tipoTarjeta) {
        this.tipoTarjeta = tipoTarjeta;
    }

    public String getNumTarjeta() {
        return numTarjeta;
    }

    public void setNumTarjeta(String numTarjeta) {
        this.numTarjeta = numTarjeta;
    }
}
