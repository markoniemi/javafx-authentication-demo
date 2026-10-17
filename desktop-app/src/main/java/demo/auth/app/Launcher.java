package demo.auth.app;

import javafx.application.Application;

/** Plain main class so the app starts from the classpath without module-path JavaFX flags. */
public final class Launcher {
  private Launcher() {}

  public static void main(String[] args) {
    Application.launch(DemoApp.class, args);
  }
}
