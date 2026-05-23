package com.gomandap.admin.domain.util

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import kotlin.math.max

object ImageCompressor {
    
    private const val MAX_DIMENSION = 1080

    /**
     * Compresses the image at the given URI to WebP format.
     * Resizes the image so its longest side is at most MAX_DIMENSION.
     * Returns a File object containing the compressed WebP image.
     */
    fun compressToWebP(context: Context, uri: Uri, quality: Int = 75): File? {
        var inputStream: InputStream? = null
        try {
            // 1. Decode bounds to get original dimensions
            inputStream = context.contentResolver.openInputStream(uri)
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeStream(inputStream, null, options)
            inputStream?.close()

            // 2. Calculate sample size for downscaling
            var sampleSize = 1
            val maxSide = max(options.outWidth, options.outHeight)
            if (maxSide > MAX_DIMENSION) {
                sampleSize = maxSide / MAX_DIMENSION
            }

            // 3. Decode actual bitmap with downscaling
            val decodeOptions = BitmapFactory.Options().apply {
                inSampleSize = sampleSize
            }
            inputStream = context.contentResolver.openInputStream(uri)
            val originalBitmap = BitmapFactory.decodeStream(inputStream, null, decodeOptions)
            inputStream?.close()

            if (originalBitmap == null) return null

            // 4. Compress to WebP
            val tempFile = File(context.cacheDir, "compressed_${System.currentTimeMillis()}.webp")
            val outputStream = FileOutputStream(tempFile)
            
            val format = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                Bitmap.CompressFormat.WEBP_LOSSY
            } else {
                @Suppress("DEPRECATION")
                Bitmap.CompressFormat.WEBP
            }

            originalBitmap.compress(format, quality, outputStream)
            
            outputStream.flush()
            outputStream.close()
            originalBitmap.recycle()

            return tempFile

        } catch (e: Exception) {
            e.printStackTrace()
            return null
        } finally {
            inputStream?.close()
        }
    }
}
