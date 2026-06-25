package com.example.quraaa;

import android.Manifest;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.RectF;
import android.graphics.pdf.PdfRenderer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.ParcelFileDescriptor;
import android.provider.Settings;

import androidx.annotation.NonNull;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String EXPLORER_CHANNEL = "quraaa/local_explorer";
    private static final String PDF_CHANNEL = "quraaa/pdf_renderer";
    private static final int STORAGE_PERMISSION_REQUEST = 4207;

    private MethodChannel.Result pendingStorageResult;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                EXPLORER_CHANNEL
        ).setMethodCallHandler(this::handleExplorerCall);

        new MethodChannel(
                flutterEngine.getDartExecutor().getBinaryMessenger(),
                PDF_CHANNEL
        ).setMethodCallHandler(this::handlePdfCall);
    }

    private void handleExplorerCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "defaultRootPath":
                result.success(defaultRootPath());
                break;
            case "hasStorageAccess":
                result.success(hasStorageAccess());
                break;
            case "requestStorageAccess":
                requestStorageAccess(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void handlePdfCall(MethodCall call, MethodChannel.Result result) {
        try {
            if ("shareText".equals(call.method)) {
                String text = call.argument("text");
                shareText(text);
                result.success(null);
                return;
            }

            String path = call.argument("path");
            if (path == null || path.trim().isEmpty()) {
                result.error("missing_path", "PDF path is required.", null);
                return;
            }

            switch (call.method) {
                case "pageCount":
                    result.success(pageCount(path));
                    break;
                case "renderPage":
                    Integer pageIndex = call.argument("pageIndex");
                    Integer width = call.argument("width");
                    if (pageIndex == null || width == null) {
                        result.error("missing_args", "Page index and width are required.", null);
                        return;
                    }

                    result.success(renderPage(path, pageIndex, width));
                    break;
                case "textLayer":
                    Integer textPageIndex = call.argument("pageIndex");
                    if (textPageIndex == null) {
                        result.error("missing_args", "Page index is required.", null);
                        return;
                    }

                    result.success(textLayer(path, textPageIndex));
                    break;
                default:
                    result.notImplemented();
                    break;
            }
        } catch (SecurityException error) {
            result.error("storage_denied", error.getMessage(), null);
        } catch (IOException error) {
            result.error("pdf_io_error", error.getMessage(), null);
        } catch (IllegalArgumentException error) {
            result.error("pdf_invalid", error.getMessage(), null);
        }
    }

    private String defaultRootPath() {
        File downloads = Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_DOWNLOADS
        );
        if (downloads != null && downloads.exists()) {
            return downloads.getAbsolutePath();
        }

        File external = Environment.getExternalStorageDirectory();
        if (external != null) {
            return external.getAbsolutePath();
        }

        return getFilesDir().getAbsolutePath();
    }

    private boolean hasStorageAccess() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            return Environment.isExternalStorageManager();
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                    == PackageManager.PERMISSION_GRANTED;
        }

        return true;
    }

    private void requestStorageAccess(MethodChannel.Result result) {
        if (hasStorageAccess()) {
            result.success(true);
            return;
        }

        if (pendingStorageResult != null) {
            result.error("request_active", "A storage permission request is already active.", null);
            return;
        }

        pendingStorageResult = result;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                Intent intent = new Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION);
                intent.setData(Uri.parse("package:" + getPackageName()));
                startActivity(intent);
            } catch (Exception error) {
                Intent intent = new Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION);
                startActivity(intent);
            }
            return;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(
                    new String[]{Manifest.permission.READ_EXTERNAL_STORAGE},
                    STORAGE_PERMISSION_REQUEST
            );
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && pendingStorageResult != null) {
            MethodChannel.Result result = pendingStorageResult;
            pendingStorageResult = null;
            result.success(hasStorageAccess());
        }
    }

    @Override
    public void onRequestPermissionsResult(
            int requestCode,
            @NonNull String[] permissions,
            @NonNull int[] grantResults
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode != STORAGE_PERMISSION_REQUEST || pendingStorageResult == null) {
            return;
        }

        boolean granted = grantResults.length > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED;
        MethodChannel.Result result = pendingStorageResult;
        pendingStorageResult = null;
        result.success(granted);
    }

    private int pageCount(String path) throws IOException {
        File file = checkedPdfFile(path);
        ParcelFileDescriptor descriptor = ParcelFileDescriptor.open(
                file,
                ParcelFileDescriptor.MODE_READ_ONLY
        );
        PdfRenderer renderer = new PdfRenderer(descriptor);
        try {
            return renderer.getPageCount();
        } finally {
            renderer.close();
            descriptor.close();
        }
    }

    private byte[] renderPage(String path, int pageIndex, int width) throws IOException {
        if (width <= 0) {
            throw new IllegalArgumentException("Render width must be positive.");
        }

        File file = checkedPdfFile(path);
        ParcelFileDescriptor descriptor = ParcelFileDescriptor.open(
                file,
                ParcelFileDescriptor.MODE_READ_ONLY
        );
        PdfRenderer renderer = new PdfRenderer(descriptor);
        PdfRenderer.Page page = null;
        Bitmap bitmap = null;

        try {
            if (pageIndex < 0 || pageIndex >= renderer.getPageCount()) {
                throw new IllegalArgumentException("PDF page index is out of range.");
            }

            page = renderer.openPage(pageIndex);
            int height = Math.max(
                    1,
                    Math.round(width * (page.getHeight() / (float) page.getWidth()))
            );
            bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
            Canvas canvas = new Canvas(bitmap);
            canvas.drawColor(Color.WHITE);
            page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY);

            ByteArrayOutputStream output = new ByteArrayOutputStream();
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, output);
            return output.toByteArray();
        } finally {
            if (page != null) {
                page.close();
            }
            if (bitmap != null) {
                bitmap.recycle();
            }
            renderer.close();
            descriptor.close();
        }
    }

    private Map<String, Object> textLayer(String path, int pageIndex) throws IOException {
        File file = checkedPdfFile(path);
        ParcelFileDescriptor descriptor = ParcelFileDescriptor.open(
                file,
                ParcelFileDescriptor.MODE_READ_ONLY
        );
        PdfRenderer renderer = new PdfRenderer(descriptor);
        PdfRenderer.Page page = null;

        try {
            if (pageIndex < 0 || pageIndex >= renderer.getPageCount()) {
                throw new IllegalArgumentException("PDF page index is out of range.");
            }

            page = renderer.openPage(pageIndex);
            Map<String, Object> layer = new HashMap<>();
            layer.put("width", page.getWidth());
            layer.put("height", page.getHeight());
            layer.put("contents", textContents(page));
            return layer;
        } finally {
            if (page != null) {
                page.close();
            }
            renderer.close();
            descriptor.close();
        }
    }

    private List<Map<String, Object>> textContents(PdfRenderer.Page page) {
        List<Map<String, Object>> items = new ArrayList<>();

        try {
            Method getTextContents = page.getClass().getMethod("getTextContents");
            Object rawContents = getTextContents.invoke(page);
            if (!(rawContents instanceof List<?>)) {
                return items;
            }

            for (Object content : (List<?>) rawContents) {
                if (content == null) {
                    continue;
                }

                Method getText = content.getClass().getMethod("getText");
                Object rawText = getText.invoke(content);
                String text = rawText instanceof String ? ((String) rawText).trim() : "";
                if (text.isEmpty()) {
                    continue;
                }

                Method getBounds = content.getClass().getMethod("getBounds");
                Object rawBounds = getBounds.invoke(content);
                List<Map<String, Object>> bounds = textBounds(rawBounds);
                if (bounds.isEmpty()) {
                    continue;
                }

                Map<String, Object> item = new HashMap<>();
                item.put("text", text);
                item.put("bounds", bounds);
                items.add(item);
            }
        } catch (ReflectiveOperationException | RuntimeException ignored) {
            return items;
        }

        return items;
    }

    private List<Map<String, Object>> textBounds(Object rawBounds) {
        List<Map<String, Object>> bounds = new ArrayList<>();
        if (!(rawBounds instanceof List<?>)) {
            return bounds;
        }

        for (Object rawBound : (List<?>) rawBounds) {
            if (!(rawBound instanceof RectF)) {
                continue;
            }

            RectF rect = (RectF) rawBound;
            if (rect.width() <= 0 || rect.height() <= 0) {
                continue;
            }

            Map<String, Object> bound = new HashMap<>();
            bound.put("left", rect.left);
            bound.put("top", rect.top);
            bound.put("right", rect.right);
            bound.put("bottom", rect.bottom);
            bounds.add(bound);
        }

        return bounds;
    }

    private void shareText(String text) {
        String trimmed = text == null ? "" : text.trim();
        if (trimmed.isEmpty()) {
            throw new IllegalArgumentException("Shared text cannot be empty.");
        }

        Intent sendIntent = new Intent(Intent.ACTION_SEND);
        sendIntent.setType("text/plain");
        sendIntent.putExtra(Intent.EXTRA_TEXT, trimmed);

        try {
            startActivity(Intent.createChooser(sendIntent, null));
        } catch (ActivityNotFoundException error) {
            throw new IllegalArgumentException("No app can share this text.");
        }
    }

    private File checkedPdfFile(String path) throws FileNotFoundException {
        File file = new File(path);
        if (!file.exists() || !file.isFile()) {
            throw new FileNotFoundException("PDF file was not found.");
        }

        if (!path.toLowerCase().endsWith(".pdf")) {
            throw new IllegalArgumentException("Only PDF files can be opened.");
        }

        return file;
    }
}
