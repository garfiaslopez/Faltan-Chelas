package modelo;

/**
 * Created by gargui3 on 19/06/16.
 */
public class Venta {

    private double subtotal = 0;
    private int maximoChelas = 24;
    private int chelasPedidas = 0;

    public double getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(double subtotal) {
        this.subtotal += subtotal;
    }

    public int getMaximoChelas() {
        return maximoChelas;
    }

    public int getChelasPedidas() {
        return chelasPedidas;
    }

    public void setChelasPedidas(int chelasPedidas) {
        this.chelasPedidas += chelasPedidas;
    }

}
