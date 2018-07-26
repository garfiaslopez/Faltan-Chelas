package com.example.gargui3.faltanchelas;

import android.app.Application;
import android.graphics.Color;
import android.support.v7.app.NotificationCompat;

import com.urbanairship.UAirship;
import com.urbanairship.push.notifications.DefaultNotificationFactory;

/**
 * Created by gargui3 on 2/08/16
 */
public class UrbanNotifications extends Application {

    @Override
    public void onCreate(){
        super.onCreate();

        UAirship.takeOff(this, new UAirship.OnReadyCallback() {

            @Override
            public void onAirshipReady(UAirship uAirship) {
                // Create a customized default notification factory
                DefaultNotificationFactory notificationFactory;
                notificationFactory = new DefaultNotificationFactory(getApplicationContext());

                // Custom notification icon
                notificationFactory.setSmallIconId(R.mipmap.notification_img);

                // The accent color for Android Lollipop+
                notificationFactory.setColor(R.color.colorAccent);

                // Set the factory on the PushManager
                uAirship.getPushManager().setNotificationFactory(notificationFactory);
                uAirship.getPushManager().setUserNotificationsEnabled(true);
            }

        });
    }

}
