package de.tum.backend;

import javax.persistence.Entity;

@Entity
public class Photo {
    private String filename;
    private String location;

    public Photo(String filename) {
        this.filename = filename;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }
}
