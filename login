import React, { useState } from "react";
import {
  StyleSheet,
  View,
  Text,
  Image,
  SafeAreaView,
  TouchableOpacity,
  Alert,
} from "react-native";
import { Input, Button } from "react-native-elements";
import { Link, useRouter } from "expo-router";
import { supabase } from "../supabase/supabaseClient";
import "react-native-url-polyfill/auto";
import * as WebBrowser from "expo-web-browser";
import * as Linking from "expo-linking";

WebBrowser.maybeCompleteAuthSession();

const LoginScreen = () => {
  // ---------- State ----------
  const [focusedInput, setFocusedInput] = useState(null);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [message, setMessage] = useState("");

  const router = useRouter();
  const commonInputContainerStyle = { borderBottomWidth: 0, height: 30 };

  // ---------- Email/Password Login ----------
  const handleLogin = async () => {
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        setMessage(error.message);
        return;
      }

      Alert.alert("Success", "Logged in!");
      router.replace("/home");
    } catch (err) {
      console.error(err);
      setMessage("Something went wrong");
    }
  };

  // ---------- Google OAuth Login ----------
  const handleGoogleLogin = async () => {
    try {
      const redirectUrl = Linking.createURL("/auth/callback", {
        scheme: "capstonereact",
      });

      const { data, error } = await supabase.auth.signInWithOAuth({
        provider: "google",
        options: { redirectTo: redirectUrl },
      });

      if (error) {
        setMessage(error.message);
        return;
      }

      if (data?.url) {
        console.log("Opening Google login page:", data.url);

        const result = await WebBrowser.openAuthSessionAsync(
          data.url,
          redirectUrl
        );

        if (result.type === "success" && result.url) {
          console.log("Returned URL:", result.url);

          // Exchange code for session
          const { data: sessionData, error: sessionError } =
            await supabase.auth.exchangeCodeForSession(result.url);

          if (sessionError) {
            console.error("Session error:", sessionError.message);
            setMessage(sessionError.message);
            return;
          }

          if (sessionData?.session) {
            console.log(
              "Logged in with Google:",
              sessionData.session.user.email
            );
            router.replace("/home");
          }
        }
      }
    } catch (err) {
      console.error("Google login error:", err);
      setMessage("Something went wrong");
    }
  };

  // ---------- UI ----------
  return (
    <SafeAreaView style={styles.container}>
      {/* Logo */}
      <Image
        source={require("../assets/Museo_Logo.png")}
        style={styles.logo}
      />

      {/* Title */}
      <Text style={styles.title}>LOGIN</Text>

      {/* Email Input */}
      <View style={styles.inputWrapper}>
        {!email && <Text style={styles.placeholderText}>Email</Text>}
        <Input
          value={email}
          onChangeText={setEmail}
          keyboardType="email-address"
          autoCapitalize="none"
          containerStyle={[
            styles.inputContainer,
            focusedInput === "email" && styles.focusedContainer,
          ]}
          inputContainerStyle={commonInputContainerStyle}
          inputStyle={styles.inputStyle}
          onFocus={() => setFocusedInput("email")}
          onBlur={() => setFocusedInput(null)}
        />
      </View>

      {/* Password Input */}
      <View style={styles.inputWrapper}>
        {!password && <Text style={styles.placeholderText}>Password</Text>}
        <Input
          value={password}
          onChangeText={setPassword}
          secureTextEntry
          containerStyle={[
            styles.inputContainer,
            focusedInput === "password" && styles.focusedContainer,
          ]}
          inputContainerStyle={commonInputContainerStyle}
          inputStyle={styles.inputStyle}
          onFocus={() => setFocusedInput("password")}
          onBlur={() => setFocusedInput(null)}
        />
      </View>

      {/* Forgot Password */}
      <TouchableOpacity style={styles.forgotPasswordContainer}>
        <Text style={styles.forgotPassword}>Forgot your password?</Text>
      </TouchableOpacity>

      {/* Login Button */}
      <Button
        title="Login with Email"
        onPress={handleLogin}
        buttonStyle={styles.loginButton}
        titleStyle={styles.loginButtonTitle}
        containerStyle={styles.loginButtonContainer}
      />

      {/* Error Message */}
      {message ? <Text style={styles.errorMsg}>{message}</Text> : null}

      {/* Signup Link */}
      <View style={styles.signupContainer}>
        <Text style={styles.signupText}>Create Account?</Text>
        <Link href="/signup" style={styles.signupLink}>
          Register
        </Link>
      </View>

      {/* Google Login Button */}
      <TouchableOpacity style={styles.googleButton} onPress={handleGoogleLogin}>
        <Image
          source={require("../assets/googlelogo.jpg")}
          style={styles.googleLogo}
        />
        <Text style={styles.googleText}>Continue with Google</Text>
      </TouchableOpacity>
    </SafeAreaView>
  );
};

export default LoginScreen;

// ---------- Styles ----------
const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    backgroundColor: "#fff",
    paddingHorizontal: 30,
    paddingTop: 60,
  },
  logo: {
    width: 200,
    height: 100,
    resizeMode: "contain",
    marginTop: 50,
    marginBottom: 30,
  },
  title: {
    fontSize: 22,
    fontWeight: "bold",
    color: "#000",
    marginBottom: 8,
  },
  inputWrapper: {
    width: "100%",
    position: "relative",
  },
  placeholderText: {
    position: "absolute",
    top: 17,
    left: 15,
    color: "#888",
    zIndex: 1,
  },
  inputContainer: {
    width: "100%",
    marginBottom: 15,
    borderWidth: 1,
    borderColor: "#ccc",
    borderRadius: 8,
    backgroundColor: "#fff",
    paddingHorizontal: 5,
  },
  focusedContainer: {
    borderColor: "#000",
    borderWidth: 2,
  },
  inputStyle: {
    fontSize: 18,
    color: "#000",
    top: 12,
    textAlignVertical: "center",
  },
  forgotPasswordContainer: {
    alignSelf: "flex-end",
    marginBottom: 30,
  },
  forgotPassword: {
    fontSize: 14,
    color: "#888",
  },
  loginButtonContainer: {
    width: "100%",
  },
  loginButton: {
    backgroundColor: "#fff",
    borderRadius: 30,
    paddingVertical: 15,
    borderWidth: 1,
    borderColor: "#000",
  },
  loginButtonTitle: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#000",
  },
  signupContainer: {
    flexDirection: "row",
    marginTop: 25,
  },
  signupText: {
    fontSize: 16,
    color: "#888",
  },
  signupLink: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#000",
    marginLeft: 5,
  },
  googleButton: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#fff",
    borderWidth: 1,
    borderColor: "#ccc",
    borderRadius: 30,
    paddingVertical: 12,
    paddingHorizontal: 20,
    marginTop: 15,
    width: "100%",
    justifyContent: "center",
  },
  googleLogo: {
    width: 20,
    height: 20,
    marginRight: 10,
    resizeMode: "contain",
  },
  googleText: {
    fontSize: 16,
    color: "#000",
  },
  errorMsg: {
    color: "red",
    marginTop: 10,
  },
});


