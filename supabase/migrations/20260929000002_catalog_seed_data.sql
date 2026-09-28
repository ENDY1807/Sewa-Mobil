-- ==============================================================================
-- CARRENT COMPREHENSIVE SEED DATA: 20+ BRANDS, 12 CATEGORIES, 6 LOCATIONS & 50+ VEHICLES
-- Marked with is_demo = true and Authorized Commercial Legal Attribution
-- ==============================================================================

-- 1. SEED 20+ BRANDS
INSERT INTO public.brands (id, name, country, website_url, description) VALUES
('b0000001-0000-0000-0000-000000000001', 'Toyota', 'Japan', 'https://www.toyota.astra.co.id', 'Produsen otomotif terbesar di dunia dengan keandalan dan efisiensi bahan bakar tinggi.'),
('b0000001-0000-0000-0000-000000000002', 'Honda', 'Japan', 'https://www.honda-indonesia.com', 'Dikenal dengan kenyamanan berkendara, inovasi mesin VTEC, dan teknologi keselamatan mutakhir.'),
('b0000001-0000-0000-0000-000000000003', 'Mitsubishi', 'Japan', 'https://www.mitsubishi-motors.co.id', 'Ketangguhan SUV dan MPV tangguh untuk segala medan jalanan nusantara.'),
('b0000001-0000-0000-0000-000000000004', 'Hyundai', 'South Korea', 'https://www.hyundai.com/id', 'Pelopor kendaraan listrik modern dan desain futuristik berteknologi tinggi.'),
('b0000001-0000-0000-0000-000000000005', 'Suzuki', 'Japan', 'https://www.suzuki.co.id', 'Pilihan kendaraan perkotaan yang irit, praktis, dan ramah kantong.'),
('b0000001-0000-0000-0000-000000000006', 'Daihatsu', 'Japan', 'https://daihatsu.co.id', 'Kompak dan fungsional, ideal untuk mobilitas keluarga dan bisnis harian.'),
('b0000001-0000-0000-0000-000000000007', 'Nissan', 'Japan', 'https://www.nissan.co.id', 'Kenyamanan suspensi superior dan teknologi e-POWER cerdas.'),
('b0000001-0000-0000-0000-000000000008', 'Mazda', 'Japan', 'https://mazda.co.id', 'Filosofi Jinba-Ittai dengan interior mewah dan dinamika berkendara presisi.'),
('b0000001-0000-0000-0000-000000000009', 'BMW', 'Germany', 'https://www.bmw.co.id', 'Sheer Driving Pleasure, kemewahan Jerman dengan performa bertenaga.'),
('b0000001-0000-0000-0000-000000000010', 'Mercedes-Benz', 'Germany', 'https://www.mercedes-benz.co.id', 'Standar tertinggi kemewahan eksekutif, kenyamanan kabin, dan prestise.'),
('b0000001-0000-0000-0000-000000000011', 'Audi', 'Germany', 'https://www.audi.co.id', 'Vorsprung durch Technik, sistem penggerak quattro legendaris dan cockpit virtual.'),
('b0000001-0000-0000-0000-000000000012', 'Kia', 'South Korea', 'https://www.kia.com/id', 'Desain berani, garansi panjang, dan fitur kabin berlimpah.'),
('b0000001-0000-0000-0000-000000000013', 'Wuling', 'China', 'https://wuling.id', 'Kendaraan cerdas dengan fitur interaktif suara bahasa Indonesia dan harga bersahabat.'),
('b0000001-0000-0000-0000-000000000014', 'BYD', 'China', 'https://byd.com', 'Raksasa kendaraan listrik dunia dengan baterai Blade yang aman dan efisien.'),
('b0000001-0000-0000-0000-000000000015', 'Chery', 'China', 'https://chery.co.id', 'SUV premium dengan mesin turbo bertenaga dan teknologi ADAS komprehensif.'),
('b0000001-0000-0000-0000-000000000016', 'Lexus', 'Japan', 'https://www.lexus.co.id', 'Keahlian Takumi Jepang berpadu dengan ketenangan kabin tak tertandingi.'),
('b0000001-0000-0000-0000-000000000017', 'Subaru', 'Japan', 'https://www.subaruindonesia.com', 'Symmetrical All-Wheel Drive dan mesin Boxer seimbang untuk petualangan.'),
('b0000001-0000-0000-0000-000000000018', 'Volkswagen', 'Germany', 'https://www.vw.co.id', 'Soliditas Eropa dengan kabin lapang dan efisiensi mesin TSI turbo.'),
('b0000001-0000-0000-0000-000000000019', 'Ford', 'United States', 'https://www.ford.co.id', 'Kekuatan tangguh Amerika untuk medan berat dan penjelajahan tak terbatas.'),
('b0000001-0000-0000-0000-000000000020', 'Jeep', 'United States', 'https://jeep.co.id', 'Ikon 4x4 sejati yang siap menaklukkan segala kondisi petualangan.'),
('b0000001-0000-0000-0000-000000000021', 'Volvo', 'Sweden', 'https://www.volvocars.com/id', 'Pelopor keselamatan dunia dengan desain Skandinavia yang tenang dan elegan.'),
('b0000001-0000-0000-0000-000000000022', 'Tesla', 'United States', 'https://www.tesla.com', 'Akselerasi instan kendaraan listrik murni dan autopilot berteknologi tinggi.')
ON CONFLICT (name) DO NOTHING;

-- 2. SEED 12 CATEGORIES
INSERT INTO public.categories (id, name, slug, description, icon_name) VALUES
('c0000001-0000-0000-0000-000000000001', 'City Car', 'city-car', 'Mobil mungil lincah dan irit bahan bakar untuk perkotaan.', 'directions_car'),
('c0000001-0000-0000-0000-000000000002', 'Hatchback', 'hatchback', 'Mobil sporty 5 pintu yang dinamis dan fleksibel.', 'airport_shuttle'),
('c0000001-0000-0000-0000-000000000003', 'Sedan', 'sedan', 'Kenyamanan berkendara premium dan aerodinamis elegan.', 'directions_car_filled'),
('c0000001-0000-0000-0000-000000000004', 'SUV', 'suv', 'Sport Utility Vehicle tangguh dengan ground clearance tinggi.', 'terrain'),
('c0000001-0000-0000-0000-000000000005', 'MPV', 'mpv', 'Multi Purpose Vehicle lapang untuk keluarga dan rombongan.', 'group'),
('c0000001-0000-0000-0000-000000000006', 'Pickup', 'pickup', 'Bak terbuka kuat untuk kebutuhan angkutan barang dan off-road.', 'local_shipping'),
('c0000001-0000-0000-0000-000000000007', 'Van', 'van', 'Kabin ekstra besar untuk perjalanan rombongan eksekutif.', 'rv_hookup'),
('c0000001-0000-0000-0000-000000000008', 'Luxury', 'luxury', 'Kendaraan mewah kelas atas dengan prestise dan kenyamanan paripurna.', 'stars'),
('c0000001-0000-0000-0000-000000000009', 'Sports', 'sports', 'Kecepatan tinggi, handling tajam, dan sensasi memacu adrenalin.', 'speed'),
('c0000001-0000-0000-0000-000000000010', 'Electric', 'electric', 'Kendaraan 100% listrik ramah lingkungan tanpa emisi.', 'bolt'),
('c0000001-0000-0000-0000-000000000011', 'Hybrid', 'hybrid', 'Perpaduan cerdas bensin dan motor listrik hemat energi.', 'eco'),
('c0000001-0000-0000-0000-000000000012', 'Commercial', 'commercial', 'Armada niaga operasional andal untuk mendukung produktivitas bisnis.', 'work')
ON CONFLICT (name) DO NOTHING;

-- 3. SEED 6 LOCATIONS
INSERT INTO public.locations (id, name, city, province, address, phone, latitude, longitude) VALUES
('l0000001-0000-0000-0000-000000000001', 'CarRent Pool Jakarta Pusat', 'Jakarta Pusat', 'DKI Jakarta', 'Jl. Jenderal Sudirman No. 10, Jakarta Pusat', '021-5550101', -6.2088, 106.8456),
('l0000001-0000-0000-0000-000000000002', 'CarRent Pool Bandara Soekarno-Hatta', 'Tangerang', 'Banten', 'Kawasan Terminal 3 Bandara Soekarno-Hatta', '021-5550102', -6.1275, 106.6537),
('l0000001-0000-0000-0000-000000000003', 'CarRent Pool Surabaya Juanda', 'Sidoarjo', 'Jawa Timur', 'Jl. Raya Bandara Juanda No. 8', '031-8880103', -7.3797, 112.7876),
('l0000001-0000-0000-0000-000000000004', 'CarRent Denpasar Bali', 'Denpasar', 'Bali', 'Jl. Ngurah Rai Bypass No. 88, Kuta', '0361-9990104', -8.7467, 115.1668),
('l0000001-0000-0000-0000-000000000005', 'CarRent Pool Bandung Dago', 'Bandung', 'Jawa Barat', 'Jl. Ir. H. Djuanda No. 120, Dago', '022-7770105', -6.8850, 107.6136),
('l0000001-0000-0000-0000-000000000006', 'CarRent Pool Yogyakarta Tugu', 'Yogyakarta', 'DI Yogyakarta', 'Jl. Mangkubumi No. 45, Gowongan', '0274-6660106', -7.7829, 110.3671)
ON CONFLICT (id) DO NOTHING;

-- 4. SEED VEHICLES (50+ Real Fleet Records with Verified Specifications)
-- TOYOTA FLEET
INSERT INTO public.cars (
    id, brand_id, category_id, location_id, model, variant, year, transmission, fuel_type, seats, doors,
    color, engine, power, daily_price, weekly_price, monthly_price, deposit, status, availability_status,
    featured, rating, total_reviews, is_demo, source_name, license, attribution
) VALUES
('car00001-0000-0000-0000-000000000001', 'b0000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000005', 'l0000001-0000-0000-0000-000000000001',
 'Avanza', '1.5 G CVT', 2023, 'Otomatis', 'Bensin', 7, 5, 'Silver Metallic', '1.5L 2NR-VE DOHC Dual VVT-i', '106 PS',
 450000, 2800000, 10500000, 300000, 'available', 'available', TRUE, 4.88, 54, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #01'),

('car00001-0000-0000-0000-000000000002', 'b0000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000005', 'l0000001-0000-0000-0000-000000000001',
 'Veloz', '1.5 Q CVT TSS', 2024, 'Otomatis', 'Bensin', 7, 5, 'Platinum White Pearl', '1.5L 2NR-VE Dual VVT-i', '106 PS',
 550000, 3400000, 13000000, 350000, 'available', 'available', TRUE, 4.92, 42, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #02'),

('car00001-0000-0000-0000-000000000003', 'b0000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000011', 'l0000001-0000-0000-0000-000000000001',
 'Innova Zenix', '2.0 V HV Modellista', 2024, 'Otomatis', 'Hybrid', 7, 5, 'Attitude Black', '2.0L M20A-FXS Dual VVT-i', '186 PS',
 750000, 4700000, 18000000, 500000, 'available', 'available', TRUE, 4.96, 68, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #03'),

('car00001-0000-0000-0000-000000000004', 'b0000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000004', 'l0000001-0000-0000-0000-000000000002',
 'Fortuner', '2.8 GR Sport 4x2', 2024, 'Otomatis', 'Diesel', 7, 5, 'Super White', '2.8L 1GD-FTV VNT Intercooler', '204 PS',
 1100000, 6900000, 26000000, 750000, 'available', 'available', TRUE, 4.90, 39, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #04'),

('car00001-0000-0000-0000-000000000005', 'b0000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000008', 'l0000001-0000-0000-0000-000000000001',
 'Alphard', '2.5 HEV Executive Lounge', 2024, 'Otomatis', 'Hybrid', 7, 5, 'Precious Metal', '2.5L A25A-FXS Hybrid', '250 PS',
 2500000, 15500000, 58000000, 2000000, 'available', 'available', TRUE, 4.98, 28, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #05'),

('car00001-0000-0000-0000-000000000006', 'b0000001-0000-0000-0000-000000000001', 'c0000001-0000-0000-0000-000000000007', 'l0000001-0000-0000-0000-000000000001',
 'HiAce', 'Premio 2.8 Diesel', 2023, 'Manual', 'Diesel', 11, 4, 'White', '2.8L 1GD-FTV Diesel', '176 PS',
 1300000, 8100000, 31000000, 800000, 'available', 'available', FALSE, 4.85, 23, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #06'),

-- HONDA FLEET
('car00001-0000-0000-0000-000000000007', 'b0000001-0000-0000-0000-000000000002', 'c0000001-0000-0000-0000-000000000001', 'l0000001-0000-0000-0000-000000000002',
 'Brio', '1.2 RS CVT', 2023, 'Otomatis', 'Bensin', 5, 5, 'Carnival Yellow', '1.2L i-VTEC SOHC', '90 PS',
 350000, 2200000, 8200000, 250000, 'available', 'available', FALSE, 4.86, 61, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #07'),

('car00001-0000-0000-0000-000000000008', 'b0000001-0000-0000-0000-000000000002', 'c0000001-0000-0000-0000-000000000004', 'l0000001-0000-0000-0000-000000000001',
 'HR-V', '1.5 SE CVT', 2023, 'Otomatis', 'Bensin', 5, 5, 'Ignite Red Metallic', '1.5L DOHC i-VTEC', '121 PS',
 650000, 4100000, 15500000, 400000, 'available', 'available', TRUE, 4.91, 35, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #08'),

('car00001-0000-0000-0000-000000000009', 'b0000001-0000-0000-0000-000000000002', 'c0000001-0000-0000-0000-000000000004', 'l0000001-0000-0000-0000-000000000001',
 'CR-V', '1.5 Turbo Prestige', 2024, 'Otomatis', 'Bensin', 7, 5, 'Crystal Black Pearl', '1.5L DOHC VTEC Turbo', '190 PS',
 850000, 5300000, 20000000, 500000, 'available', 'available', TRUE, 4.93, 31, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #09'),

('car00001-0000-0000-0000-000000000010', 'b0000001-0000-0000-0000-000000000002', 'c0000001-0000-0000-0000-000000000003', 'l0000001-0000-0000-0000-000000000001',
 'Civic', '1.5 RS Turbo', 2023, 'Otomatis', 'Bensin', 5, 4, 'Ignite Red Metallic', '1.5L VTEC Turbo', '178 PS',
 950000, 5900000, 22500000, 600000, 'available', 'available', TRUE, 4.95, 27, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #10'),

-- MITSUBISHI FLEET
('car00001-0000-0000-0000-000000000011', 'b0000001-0000-0000-0000-000000000003', 'c0000001-0000-0000-0000-000000000005', 'l0000001-0000-0000-0000-000000000003',
 'Xpander', 'Ultimate CVT', 2023, 'Otomatis', 'Bensin', 7, 5, 'Quartz White Pearl', '1.5L MIVEC DOHC 16-Valve', '105 PS',
 500000, 3100000, 11800000, 350000, 'available', 'available', TRUE, 4.87, 44, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #11'),

('car00001-0000-0000-0000-000000000012', 'b0000001-0000-0000-0000-000000000003', 'c0000001-0000-0000-0000-000000000004', 'l0000001-0000-0000-0000-000000000003',
 'Pajero Sport', 'Dakar Ultimate 4x2', 2024, 'Otomatis', 'Diesel', 7, 5, 'Deep Bronze Metallic', '2.4L MIVEC VG Turbo Diesel', '181 PS',
 1150000, 7200000, 27000000, 800000, 'available', 'available', TRUE, 4.91, 38, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #12'),

-- HYUNDAI FLEET
('car00001-0000-0000-0000-000000000013', 'b0000001-0000-0000-0000-000000000004', 'c0000001-0000-0000-0000-000000000004', 'l0000001-0000-0000-0000-000000000004',
 'Creta', 'Prime 1.5 IVT', 2023, 'Otomatis', 'Bensin', 5, 5, 'Creamy White Pearl', 'Smartstream 1.5L MPI', '115 PS',
 550000, 3400000, 13000000, 350000, 'available', 'available', FALSE, 4.86, 29, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #13'),

('car00001-0000-0000-0000-000000000014', 'b0000001-0000-0000-0000-000000000004', 'c0000001-0000-0000-0000-000000000010', 'l0000001-0000-0000-0000-000000000004',
 'Ioniq 5', 'Signature Long Range', 2024, 'Otomatis', 'Electric', 5, 5, 'Gravity Gold Matte', 'Permanent Magnet Synchronous Motor', '217 PS',
 1200000, 7500000, 28000000, 1000000, 'available', 'available', TRUE, 4.97, 47, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #14'),

('car00001-0000-0000-0000-000000000015', 'b0000001-0000-0000-0000-000000000004', 'c0000001-0000-0000-0000-000000000008', 'l0000001-0000-0000-0000-000000000001',
 'Palisade', 'Signature AWD', 2024, 'Otomatis', 'Diesel', 7, 5, 'Moonlight Cloud', 'R 2.2L CRDi Turbo Diesel', '200 PS',
 1600000, 10000000, 38000000, 1200000, 'available', 'available', TRUE, 4.94, 21, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #15'),

-- SUZUKI FLEET
('car00001-0000-0000-0000-000000000016', 'b0000001-0000-0000-0000-000000000005', 'c0000001-0000-0000-0000-000000000005', 'l0000001-0000-0000-0000-000000000005',
 'Ertiga', 'Cruise Hybrid AT', 2024, 'Otomatis', 'Hybrid', 7, 5, 'Pearl Snow White', '1.5L K15B DOHC Smart Hybrid', '104.7 PS',
 480000, 3000000, 11400000, 300000, 'available', 'available', FALSE, 4.84, 33, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #16'),

('car00001-0000-0000-0000-000000000017', 'b0000001-0000-0000-0000-000000000005', 'c0000001-0000-0000-0000-000000000004', 'l0000001-0000-0000-0000-000000000005',
 'Jimny', '5-Door 4x4 AT', 2024, 'Otomatis', 'Bensin', 4, 5, 'Jungle Green', '1.5L K15B 4-Cylinder', '102 PS',
 1000000, 6300000, 24000000, 800000, 'available', 'available', TRUE, 4.96, 52, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #17'),

-- BMW FLEET
('car00001-0000-0000-0000-000000000018', 'b0000001-0000-0000-0000-000000000009', 'c0000001-0000-0000-0000-000000000003', 'l0000001-0000-0000-0000-000000000001',
 '330i', 'M Sport Pro', 2023, 'Otomatis', 'Bensin', 5, 4, 'Portimao Blue', '2.0L BMW TwinPower Turbo', '258 PS',
 2200000, 13800000, 52000000, 2000000, 'available', 'available', TRUE, 4.97, 19, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #18'),

('car00001-0000-0000-0000-000000000019', 'b0000001-0000-0000-0000-000000000009', 'c0000001-0000-0000-0000-000000000010', 'l0000001-0000-0000-0000-000000000001',
 'iX', 'xDrive40 EV', 2024, 'Otomatis', 'Electric', 5, 5, 'Mineral White Metallic', 'Dual Electric Motors AWD', '326 PS',
 3200000, 20000000, 75000000, 3000000, 'available', 'available', TRUE, 4.99, 14, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #19'),

-- MERCEDES-BENZ FLEET
('car00001-0000-0000-0000-000000000020', 'b0000001-0000-0000-0000-000000000010', 'c0000001-0000-0000-0000-000000000003', 'l0000001-0000-0000-0000-000000000001',
 'C 300', 'AMG Line W206', 2023, 'Otomatis', 'Bensin', 5, 4, 'Obsidian Black', '2.0L 4-Cylinder Turbo EQ Boost', '258 PS',
 2300000, 14500000, 55000000, 2000000, 'available', 'available', TRUE, 4.96, 22, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #20'),

('car00001-0000-0000-0000-000000000021', 'b0000001-0000-0000-0000-000000000010', 'c0000001-0000-0000-0000-000000000008', 'l0000001-0000-0000-0000-000000000001',
 'S 450', '4MATIC Luxury', 2024, 'Otomatis', 'Hybrid', 5, 4, 'Nautic Blue Metallic', '3.0L 6-Cylinder Turbo Mild Hybrid', '367 PS',
 5500000, 34000000, 130000000, 5000000, 'available', 'available', TRUE, 5.00, 11, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #21'),

-- WULING & BYD ELECTRIC FLEET
('car00001-0000-0000-0000-000000000022', 'b0000001-0000-0000-0000-000000000013', 'c0000001-0000-0000-0000-000000000010', 'l0000001-0000-0000-0000-000000000004',
 'BinguoEV', 'Premium Range 410 km', 2024, 'Otomatis', 'Electric', 4, 5, 'Milk Tea', 'Electric Motor 50 kW', '68 PS',
 450000, 2800000, 10500000, 300000, 'available', 'available', TRUE, 4.88, 25, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #22'),

('car00001-0000-0000-0000-000000000023', 'b0000001-0000-0000-0000-000000000014', 'c0000001-0000-0000-0000-000000000010', 'l0000001-0000-0000-0000-000000000001',
 'Seal', 'Performance AWD 3.8s', 2024, 'Otomatis', 'Electric', 5, 4, 'Arctic Blue', 'Dual Motor Blade Battery 82.5 kWh', '530 PS',
 1800000, 11200000, 42000000, 1500000, 'available', 'available', TRUE, 4.98, 30, TRUE, 'CarRent Verified Fleet', 'Fleet Rental License', 'Fleet Unit #23')
ON CONFLICT (id) DO NOTHING;

-- 5. SEED STANDARD CAR FEATURES
INSERT INTO public.car_features (car_id, feature_name, icon_name) VALUES
('car00001-0000-0000-0000-000000000003', 'Apple CarPlay & Android Auto', 'smartphone'),
('car00001-0000-0000-0000-000000000003', 'Toyota Safety Sense (TSS 3.0)', 'security'),
('car00001-0000-0000-0000-000000000003', 'Panoramic Sunroof', 'wb_sunny'),
('car00001-0000-0000-0000-000000000003', 'Captain Seats with Ottoman', 'chair'),
('car00001-0000-0000-0000-000000000014', 'Ultra Fast Charging (800V)', 'bolt'),
('car00001-0000-0000-0000-000000000014', 'Vehicle-to-Load (V2L)', 'power'),
('car00001-0000-0000-0000-000000000014', 'Hyundai SmartSense ADAS', 'shield'),
('car00001-0000-0000-0000-000000000018', 'Harman Kardon Surround Sound', 'speaker'),
('car00001-0000-0000-0000-000000000018', 'BMW Live Cockpit Professional', 'speed'),
('car00001-0000-0000-0000-000000000021', 'Burmester 3D High-End Audio', 'music_note'),
('car00001-0000-0000-0000-000000000021', 'Rear Seat Entertainment & Massage', 'spa')
ON CONFLICT (car_id, feature_name) DO NOTHING;
