//
//  LoginView.swift
//  Flow
//
//  Created on 2025-11-24.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authManager = AuthenticationManager.shared
    
    var body: some View {
        ZStack {
            // 背景
            Color(red: 0.11, green: 0.11, blue: 0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo 或 标题
                VStack(spacing: 16) {
                    Image(systemName: "camera.macro")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 150, height: 150)
                        )
                        .shadow(color: .blue.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Text("Flow")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("记录你的健康生活")
                        .font(.system(size: 18))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Sign in with Apple Button
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        authManager.handleSignIn(result: result)
                    }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(height: 50)
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}

#Preview {
    LoginView()
}
