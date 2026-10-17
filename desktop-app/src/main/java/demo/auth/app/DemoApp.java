package demo.auth.app;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.stage.Stage;
import org.snapfx.SnapFX;

public class DemoApp extends Application {
  @Override
  public void start(Stage stage) {
    SnapFX snapFx = new SnapFX();
    Scene scene = new Scene(snapFx.buildLayout(), 960, 600);
    stage.setTitle("JavaFX Authentication Demo");
    stage.setScene(scene);
    snapFx.initialize(stage);
    stage.show();
  }
}
