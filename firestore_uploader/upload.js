// upload.js dosyası
const admin = require('firebase-admin');

// --- 1. DOSYA YOLLARINI DÜZENLEYİN ---
// Firebase'den indirdiğiniz güvenlik anahtarının yolu
const serviceAccount = require('./serviceAccountKey.json'); 

// YENİ DÜZENLEME 1: Yüklemek istediğiniz büyük Türkçe JSON dosyasının yolu
const data = require('./word_data_tr.json'); 

// YENİ DÜZENLEME 2: Firestore'da verileri yazmak istediğiniz koleksiyon adı
const COLLECTION_NAME = 'CategoriesTr'; 

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function uploadCategories() {
  if (!data || !data.gameData || data.gameData.length === 0) {
    console.error('Hata: JSON dosyasında yüklenecek veri bulunamadı.');
    return;
  }

  console.log(`Toplam ${data.gameData.length} kategori yüklenecek.`);
  const batch = db.batch();

  data.gameData.forEach(category => {
    // Belge ID'si olarak kategori adını kullanın ve boşlukları, eğik çizgileri kaldırın (Örn: "Ünlü Kişiler" -> "ÜnlüKişiler")
    // Ek not: Türkçe karakterler (Örn: İ, Ş, Ğ) belge ID'sinde sorun çıkarmaz, ancak URL'de sorun çıkarabilir. Yine de bu basit ID oluşturma yöntemiyle devam ediyoruz.
    const docId = category.categoryName.replace(/[\s/]+/g, ''); 
    
    // CategoriesTr koleksiyonunda yeni belge referansı oluştur
    const docRef = db.collection(COLLECTION_NAME).doc(docId); 
    
    // Veriyi toplu işleme ekle
    batch.set(docRef, category); 
  });

  try {
    // Toplu işlemi Firestore'a gönder
    await batch.commit();
    console.log(`✅ ${data.gameData.length} kategori başarıyla "${COLLECTION_NAME}" koleksiyonuna yüklendi!`);
  } catch (error) {
    console.error('❌ Veri yüklenirken bir hata oluştu:', error);
  }
}

uploadCategories();