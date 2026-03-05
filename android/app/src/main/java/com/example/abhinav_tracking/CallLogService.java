package com.example.abhinav_tracking;

import android.app.Service;
import android.content.Intent;
import android.database.Cursor;
import android.os.IBinder;
import android.provider.CallLog;
import android.util.Log;

import org.json.JSONObject;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Calendar;

public class CallLogService extends Service {

    private static long lastSavedTimestamp = 0;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        Log.d("CALL_LOG_SERVICE", "Service started");

        Cursor cursor = getContentResolver().query(
                CallLog.Calls.CONTENT_URI,
                null,
                null,
                null,
                CallLog.Calls.DATE + " DESC"
        );

        if (cursor != null && cursor.moveToFirst()) {

            String number = cursor.getString(
                    cursor.getColumnIndexOrThrow(CallLog.Calls.NUMBER));

            int duration = cursor.getInt(
                    cursor.getColumnIndexOrThrow(CallLog.Calls.DURATION));

            long timestamp = cursor.getLong(
                    cursor.getColumnIndexOrThrow(CallLog.Calls.DATE));

            Log.d("CALL_LOG_SERVICE", "Number: " + number);
            Log.d("CALL_LOG_SERVICE", "Duration: " + duration);
            Log.d("CALL_LOG_SERVICE", "Timestamp: " + timestamp);

            // ❌ Skip duration 0
            if (duration == 0) {
                cursor.close();
                stopSelf();
                return START_NOT_STICKY;
            }

            // ❌ Skip duplicates
            if (timestamp == lastSavedTimestamp) {
                Log.d("CALL_LOG_SERVICE", "Duplicate call skipped");
                cursor.close();
                stopSelf();
                return START_NOT_STICKY;
            }

            // ✔ Check today's call
            Calendar cal = Calendar.getInstance();
            cal.set(Calendar.HOUR_OF_DAY, 0);
            cal.set(Calendar.MINUTE, 0);
            cal.set(Calendar.SECOND, 0);
            cal.set(Calendar.MILLISECOND, 0);

            long todayStart = cal.getTimeInMillis();

            if (timestamp < todayStart) {
                Log.d("CALL_LOG_SERVICE", "Old call ignored");
                cursor.close();
                stopSelf();
                return START_NOT_STICKY;
            }

            lastSavedTimestamp = timestamp;

            sendCallToServer(number, duration);

            cursor.close();
        }

        stopSelf();
        return START_NOT_STICKY;
    }

    private void sendCallToServer(String number, int duration) {

        new Thread(() -> {

            try {

                URL url = new URL("https://abhinav-backend.onrender.com/api/shops/calls");

                HttpURLConnection conn = (HttpURLConnection) url.openConnection();

                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/json");
                conn.setDoOutput(true);

                JSONObject json = new JSONObject();
                json.put("phone", number);
                json.put("durationSec", duration);

                OutputStream os = conn.getOutputStream();
                os.write(json.toString().getBytes());
                os.flush();
                os.close();

                int responseCode = conn.getResponseCode();

                Log.d("CALL_LOG_SERVICE", "API Response: " + responseCode);

                conn.disconnect();

            } catch (Exception e) {
                Log.e("CALL_LOG_SERVICE", "API ERROR: " + e.getMessage());
            }

        }).start();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}