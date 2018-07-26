package modelo;

/**
 * Created by gargui3 on 12/07/16.
 */
public class Historial {

    private String numVenta;
    private String fecha;
    private String domicilioEntrega;
    private double total;

    public String getNumVenta() {
        return numVenta;
    }

    public void setNumVenta(String numVenta) {
        this.numVenta = numVenta;
    }

    public String getFecha() {
        return fecha;
    }

    public void setFecha(String fecha) {
        this.fecha = fecha;
    }

    public String getDomicilioEntrega() {
        return domicilioEntrega;
    }

    public void setDomicilioEntrega(String domicilioEntrega) {
        this.domicilioEntrega = domicilioEntrega;
    }

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }
}
