import java.util.Date;

String PHOTOS_DIRECTORY =  "data/photos_org_strip/";
String TABLES_DIRECTORY =  "data/extracted_colors/";

void setup() {
  size(760,550);
  background(10,10,10);
  noLoop();
  //analyze();
  //sumarize();
  represent();
  saveFrame("colortime.png");
}


void analyze() {
  println("--------");println("--------");
  String path = sketchPath() + "/" + PHOTOS_DIRECTORY;
  String[] filenames = listFileNames(path);
  println("photos in directory:");
  println(filenames);
  println("--------");

  for (int i = 0; i < filenames.length; i++) {
    String f  = filenames[i];
    PImage img = loadImage( path + f );
    loadPixels();
    
    Table t = new Table();
    t.addColumn("color");
    t.addColumn("color_hue");
    t.addColumn("color_sat");
    t.addColumn("color_bri");
    t.addColumn(f);
    t.addColumn("percentage");
    
    println(millis() + " > analyzing " + f);
    float total_pix = img.width * img.height; 
    
    for (int x=0; x<img.width; x++) { 
      for (int y=0; y<img.height; y++) {
        //int c = img.get(x, y);  //pixels[] is faster than get
        int c = img.pixels[y*img.width+x];

        int pxls = 1;
        TableRow row = t.findRow(str(c), 0); 
        if (row==null) {
          row = t.addRow();
          row.setInt("color", c);
          row.setFloat("color_hue", hue(c));
          row.setFloat("color_sat", saturation(c));
          row.setFloat("color_bri", brightness(c));
        } else {
          pxls = row.getInt(f) + 1;
        }
        row.setInt(f, pxls);
        float p = pxls / total_pix * 100;
        row.setString("percentage", nf(p,2,2) );
      }
    }
    t.sortReverse("percentage");
    saveTable(t, TABLES_DIRECTORY+f+".csv");
    println("done ("+(i+1)+"/"+filenames.length+")");
  }
  println("----- analysis finished");
}


void sumarize() {
  println("--------");println("--------");
  String path = sketchPath() + "/" + TABLES_DIRECTORY;
  String[] filenames = listFileNames(path);
  println("tables in directory:");
  println(filenames);
  println("--------");

  Table resume = new Table();
  resume.addColumn("file");
  for (int i=1; i<=64; i++) {
    resume.addColumn("color"+i);
    resume.addColumn("perct"+i);
  }

  for (int i = 0; i < filenames.length; i++) {
    String f  = filenames[i];
    Table t = loadTable(path + f);
    println(millis() + " > resuming " + f);
    TableRow resumen_newrow = resume.addRow();
    resumen_newrow.setString("file", f);

    for (int ir=1; ir<=64; ir++){ 
      TableRow r = t.getRow(ir);
      resumen_newrow.setInt("color"+ir,r.getInt(0));
      resumen_newrow.setFloat("perct"+ir,r.getFloat(5));
    }
    println("done ("+(i+1)+"/"+filenames.length+")");
  }
  
  saveTable(resume, "data/resume.csv");
}




void represent() {
  int offx = 10;
  int offy = height-60;
  Table t = loadTable("data/resume.csv");
  
  int diffsum = 0;
  for (int i=1; i<t.getRowCount(); i++){
    TableRow r = t.getRow(i);
    int diff = r.getInt(2);
    diffsum += diff/10;
    //rect(offx + diffsum + (i*15), offy, 10,10);
    pushMatrix();
    translate(offx + diffsum + (i*15), offy);
    rotate(PI/2);
    fill(80);
    String time = r.getString(0).substring(0,6);
    time = time.substring(1,2) + ":" + time.substring(2,4) + "." + time.substring(4,6); 
    text(time, 0,0);
    popMatrix();
    
    int persum = 15;
    for (int j=3; j<=128; j+=2) {
      int col = r.getInt(j); // color
      int per = r.getInt(j+1) * 5;
      fill( col );
      stroke(255);
      noStroke();
      rect(offx + diffsum + (i*15), persum, 15, per);
      persum += per;
    }
  }
}



// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}