# 📝 Backlog – SympAI: Yapay Zeka Destekli Sağlık Asistanı

Bu belge, SympAI projesinin geliştirme sürecindeki tüm planlanmış özellikleri, iyileştirmeleri ve hataları içermektedir.

---

## 🎯 Özellikler (Features)

### 1. Giriş ve Kayıt
- [ ] Kullanıcı kayıt olabilmeli
- [ ] Kullanıcı giriş yapabilmeli
- [ ] Şifre sıfırlama opsiyonu

### 2. Kullanıcı Seçimi
- [ ] Kullanıcı "İnsan", "Hayvan" veya "Bitki" tercihi yapabilmeli
- [ ] Seçime göre semptom giriş ekranı özelleşmeli

### 3. Semptom Girişi
- [ ] Zorunlu metin alanı (semptom tanımı)
- [ ] Opsiyonel görsel yükleme (fotoğraf desteği)
- [ ] Yüklenen görselin önizlemesi

### 4. Yapay Zeka Analizi
- [ ] NLP modeli (OpenAI API veya spaCy) ile metin analizi
- [ ] Görsel sınıflandırma modeli (TensorFlow/Keras) ile görsel analizi
- [ ] Olası tanı ve öneri üretimi
- [ ] Ciddi durumlarda sağlık hizmeti önerisi

### 5. Sonuç Ekranı
- [ ] Analiz sonucu öneriler listesi
- [ ] "Yeniden giriş yap" butonu
- [ ] Kullanıcı geri bildirimi alanı

---

## 🛠️ Teknoloji Kurulumu

- [ ] Frontend geliştirme ortamı kur (React.js veya Streamlit)
- [ ] Backend geliştirme ortamı kur (FastAPI)
- [ ] MongoDB bağlantısı yapılandır
- [ ] Görsel saklama servisi entegrasyonu (Firebase Storage veya Cloudinary)
- [ ] Hosting altyapısını kur (Vercel + Render/Railway)

---

## 🧪 Minimum Viable Product (MVP) Görevleri

- [ ] Giriş/kayıt akışını çalışır hale getir
- [ ] Semptom giriş ekranını hazırla
- [ ] Metin analizini ilk sürümde entegre et (OpenAI API)
- [ ] Sonuç ekranını oluştur
- [ ] Temel görsel yükleme ve saklama işlemini aktif et
- [ ] MVP testlerini gerçekleştir

---

## 🐞 Bilinen Hatalar / Riskler

- [ ] Büyük görsellerin yüklenme süresi uzun olabilir (optimizasyon yapılacak)
- [ ] Yanlış semptom sınıflandırması riski (model iyileştirmesi gerekebilir)
- [ ] Mobil cihaz uyumluluğu test edilmemiş durumda

---

## 💡 Gelecek Planlar

- [ ] Çok dilli destek (İngilizce/Türkçe)
- [ ] Kullanıcı profilinde geçmiş analizlerin görüntülenmesi
- [ ] Dark mode tasarımı
- [ ] Bildirim sistemi (E-posta veya push notification)
