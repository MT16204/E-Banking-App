# Makefile — shortcut chạy Flutter với --dart-define từ .env
#
# Cài đặt lần đầu:
#   cp .env.example .env      # tạo file .env
#   # điền giá trị thật vào .env
#
# Sau đó dùng:
#   make run        # chạy debug
#   make build-apk  # build APK release

# Đọc .env, bỏ qua dòng comment (#) và dòng trống
ifneq (,$(wildcard .env))
  include .env
  export
endif

DART_DEFINES = \
  --dart-define=APPWRITE_ENDPOINT=$(APPWRITE_ENDPOINT) \
  --dart-define=APPWRITE_PROJECT_ID=$(APPWRITE_PROJECT_ID) \
  --dart-define=APPWRITE_DATABASE_ID=$(APPWRITE_DATABASE_ID) \
  --dart-define=APPWRITE_RESET_PASSWORD_FUNCTION_ID=$(APPWRITE_RESET_PASSWORD_FUNCTION_ID)

.PHONY: run build-apk build-aab clean

run:
	flutter run $(DART_DEFINES)

build-apk:
	flutter build apk --release $(DART_DEFINES)

build-aab:
	flutter build appbundle --release $(DART_DEFINES)

clean:
	flutter clean