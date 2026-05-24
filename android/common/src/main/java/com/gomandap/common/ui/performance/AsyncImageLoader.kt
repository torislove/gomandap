package com.gomandap.common.ui.performance

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.BrokenImage
import androidx.compose.material.icons.filled.Image
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import coil.compose.SubcomposeAsyncImage
import com.gomandap.common.components.GomandapSkeleton
import com.gomandap.common.design.GomandapTokens

/**
 * GoMandap-themed async image composable that wraps Coil's SubcomposeAsyncImage.
 *
 * Features:
 * - Shows a shimmer placeholder (GomandapSkeleton) while loading
 * - Shows an error placeholder on failure via [GomandapImagePlaceholder]
 * - Supports memory and disk caching via Coil defaults
 * - Clips to the provided [shape] with GoMandap design tokens
 *
 * @param imageUrl The URL of the image to load. If null, shows the empty state placeholder.
 * @param contentDescription Accessibility description for the image.
 * @param modifier Modifier to be applied to the image container.
 * @param shape The shape to clip the image to. Defaults to [GomandapTokens.Shapes.medium].
 * @param contentScale How the image should be scaled within its bounds.
 */
@Composable
fun GomandapAsyncImage(
    imageUrl: String?,
    contentDescription: String?,
    modifier: Modifier = Modifier,
    shape: Shape = GomandapTokens.Shapes.medium,
    contentScale: ContentScale = ContentScale.Crop
) {
    if (imageUrl.isNullOrBlank()) {
        GomandapImagePlaceholder(
            modifier = modifier,
            shape = shape,
            isError = false
        )
        return
    }

    SubcomposeAsyncImage(
        model = imageUrl,
        contentDescription = contentDescription,
        modifier = modifier.clip(shape),
        contentScale = contentScale,
        loading = {
            GomandapSkeleton(
                modifier = Modifier.fillMaxSize(),
                shape = shape
            )
        },
        error = {
            GomandapImagePlaceholder(
                modifier = Modifier.fillMaxSize(),
                shape = shape,
                isError = true
            )
        }
    )
}

/**
 * Placeholder composable for error or empty image states in the GoMandap design system.
 *
 * Displays a centered icon on a softMist background:
 * - Error state: shows a broken image icon in slateGray
 * - Empty state: shows a generic image icon in slateGray
 *
 * @param modifier Modifier to be applied to the placeholder container.
 * @param shape The shape to clip the placeholder to. Defaults to [GomandapTokens.Shapes.medium].
 * @param isError Whether to show the error icon (broken image) or empty icon (generic image).
 */
@Composable
fun GomandapImagePlaceholder(
    modifier: Modifier = Modifier,
    shape: Shape = GomandapTokens.Shapes.medium,
    isError: Boolean = false
) {
    Box(
        modifier = modifier
            .clip(shape)
            .background(GomandapTokens.Colors.softMist),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            imageVector = if (isError) Icons.Default.BrokenImage else Icons.Default.Image,
            contentDescription = if (isError) "Image failed to load" else "No image available",
            modifier = Modifier.size(24.dp),
            tint = GomandapTokens.Colors.slateGray
        )
    }
}
