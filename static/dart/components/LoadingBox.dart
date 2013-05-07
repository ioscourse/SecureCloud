library loading_box;

import "dart:html";

class LoadingBox {
  static void show()
  {
    DocumentFragment _frag = query("#template_loadingBox").content.clone(true);
    window.document.body.append(_frag);
  }
  
  static void hide()
  {
    query(".loadingBox").remove();
  }
}