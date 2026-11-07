package com.bhagavadgita.bhagavad_gita_as_it_is

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.decorView.isSoundEffectsEnabled = false
    }

    override fun onResume() {
        super.onResume()
        window.decorView.isSoundEffectsEnabled = false
    }
}
