package de.tum.backend;

import org.springframework.http.ResponseEntity;
import org.springframework.util.Base64Utils;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;

@RestController
public class PhotoController {

    private static Base64Utils base64Utils;

    @RequestMapping(value = "/", method = RequestMethod.POST)
    public String addNewPhoto(@RequestBody String imageContents) {
//        byte[] contentInByte = base64Utils.decodeFromString(imageContents);
//
//        InputStream in = new ByteArrayInputStream(contentInByte);
//
//        BufferedImage bfimg;
//
//        try {
//            bfimg = ImageIO.read(in);
//
//            ImageIO.write(bfimg, "jpg", new File("/home/lukasz/newImage.jpg"));
//        } catch (IOException e) {
//            e.printStackTrace();
//        }

        try {
            Files.write(Paths.get("/home/lukasz/body.txt"), Arrays.asList(imageContents), Charset.forName("UTF-8"));
        } catch (IOException e) {
            e.printStackTrace();
        }

        System.out.println("POST request");

        return "Added new photo";
    }
}
