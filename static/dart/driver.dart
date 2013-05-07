import "dart:html";
import "dart:json";
import "FileManager/FileManager.dart";
import "components/MainSection.dart";
import "components/MainNav.dart";
import "components/LoadingBox.dart";
import "components/CloudSocket.dart";

main() {
  CloudSocket.init();
  FileManager.init();
  MainSection.init();
  MainNav.init();
}