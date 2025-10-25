/**
 * Turkish Word List for the "Yes or No" Game
 * Minimum 100 words across various categories
 */

const WORD_LIST = [
  // Mutfak Eşyaları (Kitchen Appliances)
  { word: 'Tost Makinesi', category: 'Mutfak Eşyaları' },
  { word: 'Blender', category: 'Mutfak Eşyaları' },
  { word: 'Mikser', category: 'Mutfak Eşyaları' },
  { word: 'Kahve Makinesi', category: 'Mutfak Eşyaları' },
  { word: 'Buzdolabı', category: 'Mutfak Eşyaları' },
  { word: 'Fırın', category: 'Mutfak Eşyaları' },
  { word: 'Bulaşık Makinesi', category: 'Mutfak Eşyaları' },
  { word: 'Mikrodalga', category: 'Mutfak Eşyaları' },
  { word: 'Çaydanlık', category: 'Mutfak Eşyaları' },
  { word: 'Tencere', category: 'Mutfak Eşyaları' },
  
  // Hayvanlar (Animals)
  { word: 'Kedi', category: 'Hayvanlar' },
  { word: 'Köpek', category: 'Hayvanlar' },
  { word: 'Aslan', category: 'Hayvanlar' },
  { word: 'Fil', category: 'Hayvanlar' },
  { word: 'Zürafa', category: 'Hayvanlar' },
  { word: 'Kelebek', category: 'Hayvanlar' },
  { word: 'Kartal', category: 'Hayvanlar' },
  { word: 'Yunus', category: 'Hayvanlar' },
  { word: 'Penguen', category: 'Hayvanlar' },
  { word: 'Timsah', category: 'Hayvanlar' },
  { word: 'Kaplumbağa', category: 'Hayvanlar' },
  { word: 'Tavşan', category: 'Hayvanlar' },
  { word: 'Sincap', category: 'Hayvanlar' },
  { word: 'Kirpi', category: 'Hayvanlar' },
  { word: 'Köpekbalığı', category: 'Hayvanlar' },
  
  // Meyveler (Fruits)
  { word: 'Elma', category: 'Meyveler' },
  { word: 'Muz', category: 'Meyveler' },
  { word: 'Portakal', category: 'Meyveler' },
  { word: 'Çilek', category: 'Meyveler' },
  { word: 'Karpuz', category: 'Meyveler' },
  { word: 'Kavun', category: 'Meyveler' },
  { word: 'Üzüm', category: 'Meyveler' },
  { word: 'Kiraz', category: 'Meyveler' },
  { word: 'Armut', category: 'Meyveler' },
  { word: 'Ananas', category: 'Meyveler' },
  
  // Ulaşım (Transportation)
  { word: 'Araba', category: 'Ulaşım' },
  { word: 'Uçak', category: 'Ulaşım' },
  { word: 'Tren', category: 'Ulaşım' },
  { word: 'Gemi', category: 'Ulaşım' },
  { word: 'Bisiklet', category: 'Ulaşım' },
  { word: 'Otobüs', category: 'Ulaşım' },
  { word: 'Motorsiklet', category: 'Ulaşım' },
  { word: 'Helikopter', category: 'Ulaşım' },
  { word: 'Metro', category: 'Ulaşım' },
  { word: 'Tramvay', category: 'Ulaşım' },
  
  // Spor (Sports)
  { word: 'Futbol', category: 'Spor' },
  { word: 'Basketbol', category: 'Spor' },
  { word: 'Voleybol', category: 'Spor' },
  { word: 'Tenis', category: 'Spor' },
  { word: 'Yüzme', category: 'Spor' },
  { word: 'Kayak', category: 'Spor' },
  { word: 'Koşu', category: 'Spor' },
  { word: 'Bisiklet', category: 'Spor' },
  { word: 'Golf', category: 'Spor' },
  { word: 'Boks', category: 'Spor' },
  
  // Elektronik (Electronics)
  { word: 'Telefon', category: 'Elektronik' },
  { word: 'Bilgisayar', category: 'Elektronik' },
  { word: 'Televizyon', category: 'Elektronik' },
  { word: 'Tablet', category: 'Elektronik' },
  { word: 'Kamera', category: 'Elektronik' },
  { word: 'Oyun Konsolu', category: 'Elektronik' },
  { word: 'Hoparlör', category: 'Elektronik' },
  { word: 'Kulaklık', category: 'Elektronik' },
  { word: 'Fare', category: 'Elektronik' },
  { word: 'Klavye', category: 'Elektronik' },
  
  // Müzik Aletleri (Musical Instruments)
  { word: 'Gitar', category: 'Müzik Aletleri' },
  { word: 'Piyano', category: 'Müzik Aletleri' },
  { word: 'Keman', category: 'Müzik Aletleri' },
  { word: 'Davul', category: 'Müzik Aletleri' },
  { word: 'Flüt', category: 'Müzik Aletleri' },
  { word: 'Saksafon', category: 'Müzik Aletleri' },
  { word: 'Trompet', category: 'Müzik Aletleri' },
  { word: 'Bağlama', category: 'Müzik Aletleri' },
  { word: 'Klarnet', category: 'Müzik Aletleri' },
  { word: 'Arp', category: 'Müzik Aletleri' },
  
  // Meslekler (Professions)
  { word: 'Doktor', category: 'Meslekler' },
  { word: 'Öğretmen', category: 'Meslekler' },
  { word: 'Mühendis', category: 'Meslekler' },
  { word: 'Avukat', category: 'Meslekler' },
  { word: 'Polis', category: 'Meslekler' },
  { word: 'İtfaiyeci', category: 'Meslekler' },
  { word: 'Aşçı', category: 'Meslekler' },
  { word: 'Pilot', category: 'Meslekler' },
  { word: 'Hemşire', category: 'Meslekler' },
  { word: 'Mimar', category: 'Meslekler' },
  
  // Kırtasiye (Stationery)
  { word: 'Kalem', category: 'Kırtasiye' },
  { word: 'Defter', category: 'Kırtasiye' },
  { word: 'Silgi', category: 'Kırtasiye' },
  { word: 'Cetvel', category: 'Kırtasiye' },
  { word: 'Makas', category: 'Kırtasiye' },
  { word: 'Yapıştırıcı', category: 'Kırtasiye' },
  { word: 'Boya Kalemi', category: 'Kırtasiye' },
  { word: 'Pergel', category: 'Kırtasiye' },
  { word: 'Dosya', category: 'Kırtasiye' },
  { word: 'Zımba', category: 'Kırtasiye' },
  
  // Doğa (Nature)
  { word: 'Ağaç', category: 'Doğa' },
  { word: 'Çiçek', category: 'Doğa' },
  { word: 'Güneş', category: 'Doğa' },
  { word: 'Ay', category: 'Doğa' },
  { word: 'Yıldız', category: 'Doğa' },
  { word: 'Göl', category: 'Doğa' },
  { word: 'Deniz', category: 'Doğa' },
  { word: 'Dağ', category: 'Doğa' },
  { word: 'Bulut', category: 'Doğa' },
  { word: 'Yağmur', category: 'Doğa' },
  
  // Ev Eşyaları (Household Items)
  { word: 'Masa', category: 'Ev Eşyaları' },
  { word: 'Sandalye', category: 'Ev Eşyaları' },
  { word: 'Yatak', category: 'Ev Eşyaları' },
  { word: 'Lamba', category: 'Ev Eşyaları' },
  { word: 'Ayna', category: 'Ev Eşyaları' },
  { word: 'Saat', category: 'Ev Eşyaları' },
  { word: 'Halı', category: 'Ev Eşyaları' },
  { word: 'Perde', category: 'Ev Eşyaları' },
  { word: 'Dolap', category: 'Ev Eşyaları' },
  { word: 'Kanepe', category: 'Ev Eşyaları' },
];

/**
 * Get a random word from the word list
 * @returns {Object} Object with 'word' and 'category' properties
 */
function getRandomWord() {
  const randomIndex = Math.floor(Math.random() * WORD_LIST.length);
  return WORD_LIST[randomIndex];
}

/**
 * Get a word by category
 * @param {string} category - Category name
 * @returns {Object} Object with 'word' and 'category' properties
 */
function getWordByCategory(category) {
  const categoryWords = WORD_LIST.filter(item => item.category === category);
  if (categoryWords.length === 0) {
    return getRandomWord(); // Fallback to random if category not found
  }
  const randomIndex = Math.floor(Math.random() * categoryWords.length);
  return categoryWords[randomIndex];
}

/**
 * Get all unique categories
 * @returns {Array<string>} Array of category names
 */
function getAllCategories() {
  return [...new Set(WORD_LIST.map(item => item.category))];
}

module.exports = {
  WORD_LIST,
  getRandomWord,
  getWordByCategory,
  getAllCategories,
};
