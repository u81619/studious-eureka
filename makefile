.PHONY: help build run test clean simulator

PROJECT_NAME = SimpleTableApp
SCHEME = SimpleTableApp
SIMULATOR_NAME = iPhone 15
SIMULATOR_OS = latest

# الألوان
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

help:
	@echo "${BLUE}أوامر بناء تطبيق iOS${NC}"
	@echo ""
	@echo "${GREEN}make build${NC}    - بناء التطبيق"
	@echo "${GREEN}make run${NC}      - تشغيل التطبيق على المحاكي"
	@echo "${GREEN}make test${NC}     - تشغيل الاختبارات"
	@echo "${GREEN}make clean${NC}    - تنظيف ملفات البناء"
	@echo "${GREEN}make simulator${NC}- إنشاء محاكي جديد"
	@echo "${GREEN}make archive${NC}  - إنشاء أرشيف للتطبيق"
	@echo "${GREEN}make help${NC}     - عرض هذه المساعدة"

build:
	@echo "${BLUE}⚙️  جاري بناء التطبيق...${NC}"
	@xcodebuild \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(SIMULATOR_NAME)" \
		clean build
	@echo "${GREEN}✅ تم بناء التطبيق بنجاح${NC}"

run:
	@echo "${BLUE}🚀 جاري تشغيل التطبيق...${NC}"
	@xcodebuild \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(SIMULATOR_NAME)" \
		clean build
	@xcrun simctl boot $(SIMULATOR_NAME) 2>/dev/null || true
	@xcrun simctl install booted ./build/Products/Debug-iphonesimulator/$(PROJECT_NAME).app
	@xcrun simctl launch booted com.example.$(PROJECT_NAME)
	@echo "${GREEN}✅ تم تشغيل التطبيق${NC}"

test:
	@echo "${BLUE}🧪 جاري تشغيل الاختبارات...${NC}"
	@xcodebuild test \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-destination "platform=iOS Simulator,name=$(SIMULATOR_NAME)" \
		-quiet
	@echo "${GREEN}✅ تم تنفيذ الاختبارات${NC}"

clean:
	@echo "${BLUE}🧹 جاري التنظيف...${NC}"
	@xcodebuild clean \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME)
	@rm -rf build
	@rm -rf ~/Library/Developer/Xcode/DerivedData
	@echo "${GREEN}✅ تم التنظيف${NC}"

simulator:
	@echo "${BLUE}📱 جاري إنشاء المحاكي...${NC}"
	@xcrun simctl create "$(SIMULATOR_NAME)" \
		com.apple.CoreSimulator.SimDeviceType.iPhone-15 \
		com.apple.CoreSimulator.SimRuntime.iOS-$(SIMULATOR_OS)
	@echo "${GREEN}✅ تم إنشاء المحاكي${NC}"

archive:
	@echo "${BLUE}📦 جاري إنشاء الأرشيف...${NC}"
	@xcodebuild archive \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME) \
		-archivePath ./build/$(PROJECT_NAME).xcarchive \
		-destination generic/platform=iOS \
		-quiet
	@echo "${GREEN}✅ تم إنشاء الأرشيف في build/$(PROJECT_NAME).xcarchive${NC}"

lint:
	@echo "${BLUE}🔍 جاري فحص الكود...${NC}"
	@if which swiftlint >/dev/null; then \
		swiftlint; \
	else \
		echo "${YELLOW}⚠️  SwiftLint غير مثبت. تثبيته..." && \
		brew install swiftlint; \
	fi
	@echo "${GREEN}✅ تم فحص الكود${NC}"

dependencies:
	@echo "${BLUE}📦 جاري تثبيت التبعيات...${NC}"
	@if ! which brew >/dev/null; then \
		echo "${RED}❌ Homebrew غير مثبت. الرجاء تثبيته أولاً${NC}"; \
		exit 1; \
	fi
	@brew install swiftlint
	@echo "${GREEN}✅ تم تثبيت التبعيات${NC}"
