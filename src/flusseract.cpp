#include <stdio.h>
#include <unistd.h>
#include <memory>     // std::unique_ptr

#include <leptonica/allheaders.h>
#include <tesseract/baseapi.h>
#include <tesseract/renderer.h>

#include "flusseract.h"
#include "logger.h"
#include "logfns.h"

FFI_PLUGIN_EXPORT tess_api_ptr_t Create() {
  logTrace("Creating Tesseract API instance.");
  tesseract::TessBaseAPI* api = new tesseract::TessBaseAPI();
  return (void*)api;
}

FFI_PLUGIN_EXPORT void Destroy(tess_api_ptr_t a) {
  logTrace("Destroying Tesseract API instance.");
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  if (api != nullptr) {
    api->Clear();
    api->End();
    delete api;
  }
}

FFI_PLUGIN_EXPORT const char* Version(tess_api_ptr_t a) {
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  const char* v = api->Version();
  return v;
}

FFI_PLUGIN_EXPORT const char* GetDataPath() {
  static tesseract::TessBaseAPI api;
  api.Init(nullptr, nullptr);
  return api.GetDatapath();
}

FFI_PLUGIN_EXPORT int Init(tess_api_ptr_t a, char* tessdataprefix, char* languages, char* configfilepath) {
  CAPTURE_STD_STREAMS()

  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  int ret;

  if (configfilepath != NULL) {
    char* configs[] = {configfilepath};
    int configs_size = 1;
    ret = api->Init(tessdataprefix, languages, tesseract::OEM_LSTM_ONLY, configs, configs_size, NULL, NULL, false);
  } else {
    ret = api->Init(tessdataprefix, languages, tesseract::OEM_LSTM_ONLY);
  }

  LOG_STD_STREAMS()
  logInfo("Tesseract initialized languages [%s] from Tesseract data path '%s'.", languages, tessdataprefix);
  return ret;
}

FFI_PLUGIN_EXPORT void Clear(tess_api_ptr_t a) {
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  if (api != nullptr) {
    api->Clear();
  }
}

FFI_PLUGIN_EXPORT void ClearPersistentCache(tess_api_ptr_t a) {
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  api->ClearPersistentCache();
}

FFI_PLUGIN_EXPORT int GetPageSegMode(tess_api_ptr_t a) {
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  return api->GetPageSegMode();
}

FFI_PLUGIN_EXPORT void SetPageSegMode(tess_api_ptr_t a, int m) {
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  tesseract::PageSegMode mode = (tesseract::PageSegMode)m;
  api->SetPageSegMode(mode);
}

FFI_PLUGIN_EXPORT bool SetVariable(tess_api_ptr_t a, char* name, char* value) {
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  return api->SetVariable(name, value);
}

FFI_PLUGIN_EXPORT void SetPixImage(tess_api_ptr_t a, pix_image_ptr_t pix) {
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  Pix* image = (Pix*)pix;
  api->SetImage(image);
  if (api->GetSourceYResolution() < 70) {
    api->SetSourceResolution(70);
  }
}

FFI_PLUGIN_EXPORT char* UTF8Text(tess_api_ptr_t a) {
  CAPTURE_STD_STREAMS()
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  char *utf8Text = api->GetUTF8Text();
  LOG_STD_STREAMS()
  return utf8Text;
}

FFI_PLUGIN_EXPORT char* HOCRText(tess_api_ptr_t a) {
  CAPTURE_STD_STREAMS()
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  char *hocrText = api->GetHOCRText(0);
  LOG_STD_STREAMS()
  return hocrText;
}

FFI_PLUGIN_EXPORT void ProcessDocumentFile(tess_api_ptr_t a, char* imagepath, char* outputbase) {
  CAPTURE_STD_STREAMS()
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  auto renderer = std::make_unique<tesseract::TessTextRenderer>(outputbase);
  bool ok = api->ProcessPages(imagepath, nullptr, 0, renderer.get());
  if (!ok) {
    fprintf(stderr, "Error during processing.\n");
  }
  LOG_STD_STREAMS()
}

FFI_PLUGIN_EXPORT bounding_boxes* GetBoundingBoxes(tess_api_ptr_t a, int pageIteratorLevel) {
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  struct bounding_boxes* box_array;
  box_array = (bounding_boxes*)malloc(sizeof(bounding_boxes));
  // linearly resize boxes array
  int realloc_threshold = 900;
  int realloc_raise = 1000;
  int capacity = 1000;
  box_array->boxes = (bounding_box*)malloc(capacity * sizeof(bounding_box));
  box_array->length = 0;
  api->Recognize(NULL);
  tesseract::ResultIterator* ri = api->GetIterator();
  tesseract::PageIteratorLevel level = (tesseract::PageIteratorLevel)pageIteratorLevel;

  if (ri != 0) {
    do {
      if (box_array->length >= realloc_threshold) {
        capacity += realloc_raise;
        box_array->boxes = (bounding_box*)realloc(box_array->boxes, capacity * sizeof(bounding_box));
        realloc_threshold += realloc_raise;
      }
      box_array->boxes[box_array->length].word = ri->GetUTF8Text(level);
      box_array->boxes[box_array->length].confidence = ri->Confidence(level);
      ri->BoundingBox(level, &box_array->boxes[box_array->length].x1, &box_array->boxes[box_array->length].y1,
              &box_array->boxes[box_array->length].x2, &box_array->boxes[box_array->length].y2);
      box_array->length++;
    } while (ri->Next(level));
  }

  return box_array;
}

FFI_PLUGIN_EXPORT bounding_boxes* GetBoundingBoxesVerbose(tess_api_ptr_t a) {
  using namespace tesseract;
  tesseract::TessBaseAPI* api = (tesseract::TessBaseAPI*)a;
  struct bounding_boxes* box_array;
  box_array = (bounding_boxes*)malloc(sizeof(bounding_boxes));
  // linearly resize boxes array
  int realloc_threshold = 900;
  int realloc_raise = 1000;
  int capacity = 1000;
  box_array->boxes = (bounding_box*)malloc(capacity * sizeof(bounding_box));
  box_array->length = 0;
  api->Recognize(NULL);
  int block_num = 0;
  int par_num = 0;
  int line_num = 0;
  int word_num = 0;

  ResultIterator* res_it = api->GetIterator();
  while (!res_it->Empty(RIL_BLOCK)) {
    if (res_it->Empty(RIL_WORD)) {
      res_it->Next(RIL_WORD);
      continue;
    }
    // Add rows for any new block/paragraph/textline.
    if (res_it->IsAtBeginningOf(RIL_BLOCK)) {
      block_num++;
      par_num = 0;
      line_num = 0;
      word_num = 0;
    }
    if (res_it->IsAtBeginningOf(RIL_PARA)) {
      par_num++;
      line_num = 0;
      word_num = 0;
    }
    if (res_it->IsAtBeginningOf(RIL_TEXTLINE)) {
      line_num++;
      word_num = 0;
    }
    word_num++;

    if (box_array->length >= realloc_threshold) {
      capacity += realloc_raise;
      box_array->boxes = (bounding_box*)realloc(box_array->boxes, capacity * sizeof(bounding_box));
      realloc_threshold += realloc_raise;
    }

    box_array->boxes[box_array->length].word = res_it->GetUTF8Text(RIL_WORD);
    box_array->boxes[box_array->length].confidence = res_it->Confidence(RIL_WORD);
    res_it->BoundingBox(RIL_WORD, &box_array->boxes[box_array->length].x1, &box_array->boxes[box_array->length].y1,
              &box_array->boxes[box_array->length].x2, &box_array->boxes[box_array->length].y2);

    // block, para, line, word numbers
    box_array->boxes[box_array->length].block_num = block_num;
    box_array->boxes[box_array->length].par_num = par_num;
    box_array->boxes[box_array->length].line_num = line_num;
    box_array->boxes[box_array->length].word_num = word_num;

    box_array->length++;
    res_it->Next(RIL_WORD);
  }

  return box_array;
}

FFI_PLUGIN_EXPORT pix_image_ptr_t CreatePixImageByFilePath(char* imagepath) {
  CAPTURE_STD_STREAMS()
  Pix* image = pixRead(imagepath);
  LOG_STD_STREAMS()
  logTrace("Image loaded from file '%s': %p.", imagepath, image);
  return (void*)image;
}

FFI_PLUGIN_EXPORT pix_image_ptr_t CreatePixImageFromBytes(uint8_t* data, int size) {
  CAPTURE_STD_STREAMS()
  Pix* image = pixReadMem(data, (size_t)size);
  LOG_STD_STREAMS()
  logTrace("Image loaded from memory: %p.", image);
  return (void*)image;
}

FFI_PLUGIN_EXPORT int32_t GetPixImageWidth(pix_image_ptr_t pix) {
  CAPTURE_STD_STREAMS()
  Pix* img = (Pix*)pix;
  LOG_STD_STREAMS()
  return pixGetWidth(img);
}

FFI_PLUGIN_EXPORT int32_t GetPixImageHeight(pix_image_ptr_t pix) {
  CAPTURE_STD_STREAMS()
  Pix* img = (Pix*)pix;
  LOG_STD_STREAMS()
  return pixGetHeight(img);
}

FFI_PLUGIN_EXPORT void DestroyPixImage(pix_image_ptr_t pix) {
  CAPTURE_STD_STREAMS()
  Pix* img = (Pix*)pix;
  pixDestroy(&img);
  LOG_STD_STREAMS()
}
