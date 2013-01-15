
package com.peer1.internetmap;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Toast;
import android.view.Surface;
import android.view.SurfaceView;
import android.view.SurfaceHolder;
import android.view.View;
import android.view.View.OnClickListener;
import android.util.Log;

public class InternetMap extends Activity implements SurfaceHolder.Callback
{

    private static String TAG = "InternetMap";

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        Log.i(TAG, "onCreate()");

        nativeOnCreate();
        
        setContentView(R.layout.main);
        SurfaceView surfaceView = (SurfaceView)findViewById(R.id.surfaceview);
        surfaceView.getHolder().addCallback(this);
        surfaceView.setOnClickListener(new OnClickListener() {
                public void onClick(View view) {
                    Toast toast = Toast.makeText(InternetMap.this,
                                                 "Test tap overlay",
                                                 Toast.LENGTH_LONG);
                    toast.show();
                }});
    }

    public String readFileAsString(String filePath) throws java.io.IOException
    {
    	InputStream inputStream = getAssets().open(filePath);
    	BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
        String line, results = "";
        while( ( line = reader.readLine() ) != null)
        {
            results += line;
            results += '\n';
        }
        reader.close();
        return results;
    }
    
    @Override
    protected void onResume() {
        super.onResume();
        Log.i(TAG, "onResume()");
        nativeOnResume();
    }
    
    @Override
    protected void onPause() {
        super.onPause();
        Log.i(TAG, "onPause()");
        nativeOnPause();
    }

    @Override
    protected void onStop() {
        super.onDestroy();
        Log.i(TAG, "onStop()");
        nativeOnStop();
    }

    public void surfaceChanged(SurfaceHolder holder, int format, int w, int h) {
        nativeSetSurface(holder.getSurface());
    }

    public void surfaceCreated(SurfaceHolder holder) {
    }

    public void surfaceDestroyed(SurfaceHolder holder) {
        nativeSetSurface(null);
    }


    public native void nativeOnCreate();
    public native void nativeOnResume();
    public native void nativeOnPause();
    public native void nativeOnStop();
    public native void nativeSetSurface(Surface surface);

    static {
        System.loadLibrary("internetmaprenderer");
    }

}
