#include "common.h"

#ifndef FLUSSERACT_H
#define FLUSSERACT_H

#ifdef __cplusplus
extern "C" {
#endif

typedef void* tess_api_ptr_t;
typedef void* pix_image_ptr_t;

struct bounding_box {
    int x1, y1, x2, y2;
    char* word;
    float confidence;
    int block_num, par_num, line_num, word_num;
};

struct bounding_boxes {
    int length;
    struct bounding_box* boxes;
};

FFI_PLUGIN_EXPORT tess_api_ptr_t Create(void);
FFI_PLUGIN_EXPORT void Destroy(tess_api_ptr_t);

FFI_PLUGIN_EXPORT const char* Version(tess_api_ptr_t);
FFI_PLUGIN_EXPORT const char* GetDataPath();

FFI_PLUGIN_EXPORT int Init(tess_api_ptr_t, char*, char*, char*);

FFI_PLUGIN_EXPORT void Clear(tess_api_ptr_t);
FFI_PLUGIN_EXPORT void ClearPersistentCache(tess_api_ptr_t);

FFI_PLUGIN_EXPORT int GetPageSegMode(tess_api_ptr_t);
FFI_PLUGIN_EXPORT void SetPageSegMode(tess_api_ptr_t, int);

FFI_PLUGIN_EXPORT bool SetVariable(tess_api_ptr_t, char*, char*);
FFI_PLUGIN_EXPORT void SetPixImage(tess_api_ptr_t, pix_image_ptr_t);

FFI_PLUGIN_EXPORT char* UTF8Text(tess_api_ptr_t);
FFI_PLUGIN_EXPORT char* HOCRText(tess_api_ptr_t);

FFI_PLUGIN_EXPORT void ProcessDocumentFile(tess_api_ptr_t, char*, char*);

FFI_PLUGIN_EXPORT struct bounding_boxes* GetBoundingBoxes(tess_api_ptr_t, int);
FFI_PLUGIN_EXPORT struct bounding_boxes* GetBoundingBoxesVerbose(tess_api_ptr_t);

FFI_PLUGIN_EXPORT pix_image_ptr_t CreatePixImageByFilePath(char*);
FFI_PLUGIN_EXPORT pix_image_ptr_t CreatePixImageFromBytes(uint8_t*, int);
FFI_PLUGIN_EXPORT int32_t GetPixImageWidth(pix_image_ptr_t);
FFI_PLUGIN_EXPORT int32_t GetPixImageHeight(pix_image_ptr_t);
FFI_PLUGIN_EXPORT void DestroyPixImage(pix_image_ptr_t);

#ifdef __cplusplus
}
#endif /* extern "C" */

#endif // FLUSSERACT_H