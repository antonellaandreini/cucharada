# lib/tasks/generate_recipes.rake
#
# Genera ~5000 recetas argentinas curadas y las guarda en db/seeds/recipes_data.json
# Ejecutar una sola vez: rails generate_recipes
#
# NO requiere API externa — genera las recetas localmente con templates curados.

namespace :recipes do
  desc "Genera recetas argentinas curadas y las guarda en db/seeds/recipes_data.json"
  task generate: :environment do
    OUTPUT_FILE = Rails.root.join("db/seeds/recipes_data.json")
    TOTAL_TARGET = 5000

    CHEFS = {
      "Paulina Cocina" => {
        style: :casual,
        specialties: [:entradas, :pastas, :carnes, :rapidas, :economicas, :pollo, :guisos, :sandwiches, :milanesas, :tortillas, :ensaladas, :salsas, :acompañamientos, :cerdo, :pizzas, :empanadas, :tartas, :vegetariano, :desayunos, :chicos]
      },
      "Mauricio Betular" => {
        style: :pastelero,
        specialties: [:dulces, :tortas, :galletitas, :helados, :budines, :alfajores, :panificados, :desayunos, :navidad, :mermeladas, :entradas, :bebidas, :pastas, :salsas, :acompañamientos, :ensaladas, :chicos, :rapidas, :tartas, :empanadas]
      },
      "Ariel Rodriguez Palacios" => {
        style: :familiar,
        specialties: [:carnes, :guisos, :asado, :pastas, :sopas, :pollo, :cerdo, :milanesas, :tartas, :pescados, :empanadas, :tortillas, :sandwiches, :acompañamientos, :salsas, :economicas, :rapidas, :ensaladas, :entradas, :navidad]
      },
      "Narda Lepes" => {
        style: :moderna,
        specialties: [:ensaladas, :vegetariano, :pescados, :entradas, :sopas, :acompañamientos, :salsas, :pastas, :pollo, :rapidas, :desayunos, :panificados, :mermeladas, :bebidas, :dulces, :tartas, :cerdo, :carnes, :guisos, :pizzas]
      },
      "Maru Botana" => {
        style: :maternal,
        specialties: [:tortas, :dulces, :galletitas, :budines, :alfajores, :helados, :desayunos, :chicos, :panificados, :navidad, :mermeladas, :tartas, :empanadas, :entradas, :bebidas, :pastas, :ensaladas, :rapidas, :acompañamientos, :salsas]
      },
      "Christophe Krywonis" => {
        style: :elegante,
        specialties: [:pescados, :entradas, :carnes, :salsas, :sopas, :asado, :pastas, :ensaladas, :acompañamientos, :pollo, :cerdo, :dulces, :tortas, :helados, :panificados, :tartas, :navidad, :guisos, :milanesas, :vegetariano]
      },
      "Dolli Irigoyen" => {
        style: :tradicional,
        specialties: [:guisos, :empanadas, :asado, :carnes, :sopas, :tartas, :economicas, :pastas, :milanesas, :cerdo, :pollo, :tortillas, :sandwiches, :acompañamientos, :salsas, :entradas, :dulces, :alfajores, :panificados, :mermeladas]
      }
    }.freeze

    # ========================================================================
    # RECETAS POR CATEGORÍA — templates con título, descripción, ingredientes y pasos
    # ========================================================================
    RECIPE_TEMPLATES = {
      entradas: [
        { title: "Provoleta a la parrilla", ingredients: [["Provolone", "300", "g", nil], ["Orégano", "1", "cucharadita", "seco"], ["Aceite de oliva", "1", "cucharada", nil], ["Tomate", "1", "unidad", "en rodajas"], ["Ají molido", "1", "pizca", nil]], prep: 5, cook: 10, servings: 4, steps: ["Cortá el provolone en rodajas gruesas de 1 cm.", "Poné la parrilla a fuego medio-alto bien caliente.", "Colocá el queso sobre la parrilla o en una provolonera.", "Cociná hasta que se dore abajo y empiece a burbujear.", "Servilo con orégano, un chorrito de aceite de oliva y ají molido."] },
        { title: "Empanadas de jamón y queso fritas", ingredients: [["Tapas de empanadas", "12", "unidad", "para freír"], ["Jamón cocido", "200", "g", "picado"], ["Queso mozzarella", "200", "g", "en cubos"], ["Aceite de girasol", "500", "ml", "para freír"]], prep: 15, cook: 15, servings: 6, steps: ["Mezclá el jamón picado con los cubos de mozzarella.", "Poné una cucharada generosa del relleno en cada tapa.", "Cerrá haciendo el repulgue bien apretado para que no se abran.", "Calentá el aceite a 180°C en una olla profunda.", "Freí las empanadas de a 2-3 hasta que estén doradas.", "Sacalas y dejalas escurrir sobre papel absorbente."] },
        { title: "Hummus de garbanzos con pimentón", ingredients: [["Garbanzos", "400", "g", "cocidos"], ["Tahini", "2", "cucharada", nil], ["Limón", "1", "unidad", "jugo"], ["Ajo", "1", "diente", "picado"], ["Aceite de oliva", "3", "cucharada", nil], ["Pimentón ahumado", "1", "cucharadita", nil], ["Sal", "1", "pizca", nil]], prep: 10, cook: 0, servings: 6, steps: ["Escurrí los garbanzos y reservá un poco del líquido.", "Procesá los garbanzos con el tahini, jugo de limón y ajo.", "Agregá aceite de oliva de a poco mientras procesás.", "Si queda muy espeso, agregá un poco del líquido de los garbanzos.", "Serví en un plato con un chorrito de aceite y pimentón ahumado por encima."] },
        { title: "Bruschetta de tomate y albahaca", ingredients: [["Pan francés", "1", "unidad", "en rodajas"], ["Tomate", "3", "unidad", "en cubos"], ["Albahaca", "6", "hojas", "frescas"], ["Ajo", "1", "diente", nil], ["Aceite de oliva", "2", "cucharada", nil], ["Sal", "1", "pizca", nil]], prep: 10, cook: 5, servings: 4, steps: ["Cortá el pan en rodajas y tostalas en el horno o parrilla.", "Frotá cada rodaja con el diente de ajo.", "Mezclá el tomate en cubos con albahaca picada, aceite y sal.", "Poné una cucharada generosa de la mezcla sobre cada pan.", "Servilo enseguida para que esté crocante."] },
        { title: "Matambre arrollado", ingredients: [["Matambre de vaca", "1", "kg", nil], ["Huevo", "3", "unidad", "duros"], ["Morrón rojo", "1", "unidad", "en tiras"], ["Zanahoria", "2", "unidad", "hervidas"], ["Aceitunas verdes", "100", "g", nil], ["Ajo", "3", "diente", "picados"], ["Perejil", "3", "cucharada", "picado"], ["Sal", "1", "cucharadita", nil], ["Pimienta negra", "1", "pizca", nil]], prep: 30, cook: 90, servings: 8, steps: ["Desengrasá el matambre y abrilo bien sobre la mesada.", "Condimentá con ajo, perejil, sal y pimienta.", "Distribuí las zanahorias, huevos duros cortados, morrones y aceitunas.", "Enrollalo bien apretado y atalo con hilo de cocina.", "Envolvelo en papel film y después en papel aluminio.", "Herví en agua con sal durante 1 hora y media.", "Sacalo, dejalo enfriar y llevalo a la heladera con peso encima.", "Al día siguiente cortalo en rodajas finas para servir."] },
        { title: "Tostadas de palta y huevo", ingredients: [["Pan de campo", "4", "rebanada", nil], ["Palta", "2", "unidad", "maduras"], ["Huevo", "4", "unidad", nil], ["Limón", "1", "unidad", "jugo"], ["Sal", "1", "pizca", nil], ["Ají molido", "1", "pizca", nil]], prep: 5, cook: 5, servings: 4, steps: ["Tostá las rebanadas de pan.", "Pisá las paltas con un tenedor, agregá limón y sal.", "Hacé los huevos fritos o poché.", "Untá las tostadas con la palta pisada.", "Poné un huevo encima de cada una y terminá con ají molido."] },
        { title: "Tabla de fiambres y quesos", ingredients: [["Jamón crudo", "150", "g", "feteado"], ["Salame", "150", "g", "en rodajas"], ["Queso de cabra", "100", "g", nil], ["Queso roquefort", "100", "g", nil], ["Aceitunas negras", "100", "g", nil], ["Aceitunas verdes", "100", "g", nil], ["Nuez", "50", "g", nil]], prep: 15, cook: 0, servings: 6, steps: ["Disponé los fiambres enrollados o doblados en una tabla grande.", "Cortá los quesos en porciones y distribuilos.", "Agregá las aceitunas en bowls pequeños.", "Sumá las nueces en un sector de la tabla.", "Podés agregar grisines, pan y alguna mermelada para acompañar."] },
        { title: "Rabas a la romana", ingredients: [["Calamar", "500", "g", "en anillos"], ["Harina 000", "150", "g", nil], ["Huevo", "1", "unidad", nil], ["Cerveza rubia", "100", "ml", nil], ["Aceite de girasol", "500", "ml", "para freír"], ["Limón", "1", "unidad", "en gajos"], ["Sal", "1", "pizca", nil]], prep: 15, cook: 10, servings: 4, steps: ["Limpiá los calamares y cortalos en anillos.", "Preparé la mezcla con harina, huevo, cerveza y sal.", "Pasá los anillos por la mezcla.", "Calentá el aceite a 180°C.", "Freí los anillos hasta que estén dorados y crocantes.", "Escurrilos sobre papel absorbente y serví con limón."] },
        { title: "Bastoncitos de mozzarella", ingredients: [["Queso mozzarella", "400", "g", "en bastones"], ["Huevo", "2", "unidad", nil], ["Pan rallado", "200", "g", nil], ["Harina 000", "100", "g", nil], ["Orégano", "1", "cucharadita", nil], ["Aceite de girasol", "500", "ml", "para freír"]], prep: 20, cook: 10, servings: 6, steps: ["Cortá la mozzarella en bastones de 1 cm de grosor.", "Pasalos por harina, después por huevo batido y por último por pan rallado con orégano.", "Repetí el paso del huevo y pan rallado para doble cobertura.", "Llvalos al freezer 30 minutos.", "Freílos en aceite caliente hasta que estén dorados.", "Servilos calientes con salsa fileto."] },
        { title: "Pinchos de pollo y morrón", ingredients: [["Pechuga de pollo", "500", "g", "en cubos"], ["Morrón rojo", "1", "unidad", "en trozos"], ["Morrón verde", "1", "unidad", "en trozos"], ["Cebolla", "1", "unidad", "en trozos"], ["Aceite de oliva", "2", "cucharada", nil], ["Orégano", "1", "cucharadita", nil], ["Pimentón dulce", "1", "cucharadita", nil]], prep: 15, cook: 15, servings: 4, steps: ["Mariná los cubos de pollo con aceite, orégano y pimentón.", "Armá los pinchos alternando pollo, morrón y cebolla.", "Cociná en la parrilla o plancha a fuego medio.", "Dales vuelta cada 3-4 minutos.", "Están listos cuando el pollo esté cocido y los vegetales tiernos."] },
        { title: "Fainá", ingredients: [["Harina de garbanzo", "200", "g", nil], ["Agua", "500", "ml", nil], ["Aceite de oliva", "3", "cucharada", nil], ["Sal", "1", "cucharadita", nil], ["Pimienta negra", "1", "pizca", nil]], prep: 10, cook: 20, servings: 6, steps: ["Mezclá la harina de garbanzo con el agua fría y dejá reposar 2 horas.", "Precalentá el horno a 220°C con una pizzera aceitada adentro.", "Sacá la espuma que se formó en la mezcla.", "Agregá la sal, pimienta y 2 cucharadas de aceite.", "Volcá la preparación en la pizzera caliente.", "Horneá 15-20 minutos hasta que esté dorada y firme."] },
        { title: "Pionono salado de atún", ingredients: [["Pionono", "1", "unidad", nil], ["Atún en lata", "2", "unidad", "escurridos"], ["Queso crema", "200", "g", nil], ["Tomate", "2", "unidad", "en rodajas finas"], ["Huevo", "3", "unidad", "duros picados"], ["Mayonesa", "3", "cucharada", nil]], prep: 15, cook: 0, servings: 8, steps: ["Abrí el pionono sobre papel film.", "Untalo con queso crema.", "Mezclá el atún con la mayonesa y los huevos picados.", "Distribuí la mezcla sobre el pionono.", "Agregá las rodajas de tomate.", "Enrollalo con ayuda del papel film y llevalo a la heladera 1 hora.", "Cortalo en rodajas para servir."] },
      ],
      empanadas: [
        { title: "Empanadas de carne cortada a cuchillo", ingredients: [["Tapas de empanadas", "12", "unidad", "para horno"], ["Carne picada especial", "500", "g", nil], ["Cebolla", "3", "unidad", "picadas"], ["Huevo", "2", "unidad", "duros picados"], ["Aceitunas verdes", "12", "unidad", nil], ["Comino", "1", "cucharadita", nil], ["Pimentón dulce", "1", "cucharadita", nil], ["Ají molido", "1", "cucharadita", nil], ["Grasa vacuna", "2", "cucharada", nil]], prep: 30, cook: 25, servings: 12, steps: ["Derretí la grasa y rehogá la cebolla hasta que esté transparente.", "Agregá la carne y cociná hasta que pierda el color rojo.", "Condimentá con comino, pimentón y ají molido.", "Dejá enfriar el relleno y agregá los huevos picados.", "Rellenó cada tapa con una cucharada del relleno y una aceituna.", "Cerrá con repulgue y pintá con huevo batido.", "Horneá a 200°C por 20-25 minutos."] },
        { title: "Empanadas tucumanas", ingredients: [["Tapas de empanadas", "12", "unidad", "para horno"], ["Matambre de vaca", "500", "g", "picado fino"], ["Cebolla de verdeo", "4", "unidad", "picadas"], ["Comino", "2", "cucharadita", nil], ["Pimentón dulce", "1", "cucharada", nil], ["Grasa vacuna", "3", "cucharada", nil], ["Huevo", "2", "unidad", "duros"], ["Papa", "1", "unidad", "hervida y en cubos"]], prep: 40, cook: 25, servings: 12, steps: ["Cortá el matambre en cubos bien chicos a cuchillo.", "Rehogá la cebolla de verdeo en la grasa.", "Agregá la carne y cociná a fuego medio.", "Condimentá con comino y pimentón generosamente.", "Incorporá la papa en cubos y mezclá.", "Dejá enfriar y agregá el huevo duro picado.", "Rellenó, cerrá con repulgue y horneá a 200°C por 20 minutos."] },
        { title: "Empanadas de humita", ingredients: [["Tapas de empanadas", "12", "unidad", "para horno"], ["Choclo", "4", "unidad", "desgranados"], ["Cebolla", "2", "unidad", "picada"], ["Queso cremoso", "200", "g", "en cubos"], ["Manteca", "2", "cucharada", nil], ["Pimentón dulce", "1", "cucharadita", nil], ["Sal", "1", "cucharadita", nil]], prep: 25, cook: 25, servings: 12, steps: ["Derretí la manteca y rehogá la cebolla.", "Agregá los granos de choclo y cociná 10 minutos.", "Condimentá con pimentón y sal.", "Dejá enfriar y mezclá con el queso cremoso en cubos.", "Rellenó las tapas y cerrá con repulgue.", "Horneá a 200°C hasta que estén doradas."] },
        { title: "Empanadas salteñas de pollo", ingredients: [["Tapas de empanadas", "12", "unidad", "para horno"], ["Pechuga de pollo", "400", "g", "hervida y desmenuzada"], ["Cebolla de verdeo", "4", "unidad", "picadas"], ["Papa", "1", "unidad", "hervida en cubos"], ["Comino", "1", "cucharadita", nil], ["Pimentón dulce", "1", "cucharada", nil], ["Ají molido", "1", "cucharadita", nil], ["Aceitunas verdes", "12", "unidad", nil]], prep: 30, cook: 25, servings: 12, steps: ["Rehogá la cebolla de verdeo en aceite.", "Agregá el pollo desmenuzado y la papa.", "Condimentá con comino, pimentón y ají.", "Dejá enfriar bien el relleno.", "Armá las empanadas con una aceituna en cada una.", "Cerrá con repulgue y horneá a 200°C por 20 minutos."] },
        { title: "Empanadas de jamón y queso", ingredients: [["Tapas de empanadas", "12", "unidad", "para horno"], ["Jamón cocido", "300", "g", "picado"], ["Queso mozzarella", "300", "g", "en cubos"], ["Orégano", "1", "cucharadita", nil]], prep: 10, cook: 20, servings: 12, steps: ["Mezclá el jamón picado con los cubos de mozzarella.", "Agregá orégano y mezclá bien.", "Poné relleno en cada tapa.", "Cerrá con repulgue o con tenedor.", "Horneá a 200°C por 20 minutos hasta que estén doradas."] },
        { title: "Empanadas árabes de carne", ingredients: [["Tapas de empanadas", "12", "unidad", "para horno"], ["Carne picada especial", "400", "g", nil], ["Cebolla", "2", "unidad", "picada fina"], ["Tomate", "1", "unidad", "picado"], ["Limón", "1", "unidad", "jugo"], ["Pimienta de Jamaica", "1", "cucharadita", nil], ["Pimienta negra", "1", "pizca", nil]], prep: 20, cook: 20, servings: 12, steps: ["Mezclá la carne cruda con cebolla, tomate y jugo de limón.", "Condimentá con pimienta de Jamaica y pimienta negra.", "Este relleno va crudo.", "Rellenó las tapas formando triángulos.", "Cerrá bien los bordes.", "Horneá a 200°C hasta que estén doradas y la carne cocida."] },
        { title: "Empanadas de espinaca y ricota", ingredients: [["Tapas de empanadas", "12", "unidad", "para horno"], ["Espinaca", "300", "g", "cocida y escurrida"], ["Ricota", "250", "g", nil], ["Cebolla", "1", "unidad", "picada"], ["Nuez moscada", "1", "pizca", nil], ["Sal", "1", "pizca", nil], ["Huevo", "1", "unidad", nil]], prep: 15, cook: 20, servings: 12, steps: ["Rehogá la cebolla hasta que esté transparente.", "Mezclá la espinaca escurrida con la ricota y el huevo.", "Agregá la cebolla, nuez moscada y sal.", "Rellenó las tapas y cerrá.", "Horneá a 200°C por 20 minutos."] },
        { title: "Empanadas de cordero patagónicas", ingredients: [["Tapas de empanadas", "12", "unidad", "para horno"], ["Cordero", "500", "g", "picado"], ["Cebolla", "2", "unidad", "picada"], ["Morrón rojo", "1", "unidad", "picado"], ["Comino", "1", "cucharadita", nil], ["Tomillo", "1", "cucharadita", nil], ["Aceite de oliva", "2", "cucharada", nil]], prep: 30, cook: 25, servings: 12, steps: ["Rehogá la cebolla y el morrón en aceite de oliva.", "Agregá el cordero picado y cociná hasta dorar.", "Condimentá con comino y tomillo.", "Dejá enfriar el relleno.", "Armá las empanadas y cerrá con repulgue.", "Horneá a 200°C por 20-25 minutos."] },
      ],
      tartas: [
        { title: "Tarta de zapallitos", ingredients: [["Tapa de tarta", "1", "unidad", nil], ["Zapallito verde", "4", "unidad", "en rodajas"], ["Cebolla", "1", "unidad", "picada"], ["Huevo", "3", "unidad", nil], ["Crema de leche", "200", "ml", nil], ["Queso cremoso", "150", "g", nil], ["Sal", "1", "pizca", nil]], prep: 15, cook: 35, servings: 6, steps: ["Forré una tartera con la tapa de tarta y pinchá la base.", "Rehogá la cebolla y los zapallitos en rodajas.", "Batí los huevos con la crema y sal.", "Distribuí los zapallitos y cebolla sobre la tapa.", "Volcá la mezcla de huevos y crema.", "Agregá trocitos de queso cremoso.", "Horneá a 180°C por 30-35 minutos."] },
        { title: "Tarta de choclo y queso", ingredients: [["Tapa de tarta", "2", "unidad", nil], ["Choclo en lata", "2", "unidad", "escurridos"], ["Cebolla", "1", "unidad", "picada"], ["Queso cremoso", "200", "g", nil], ["Huevo", "3", "unidad", nil], ["Crema de leche", "150", "ml", nil]], prep: 15, cook: 30, servings: 8, steps: ["Forré la tartera con una tapa y pinchá la base.", "Rehogá la cebolla y mezclala con el choclo.", "Batí los huevos con la crema.", "Distribuí el choclo, la cebolla y el queso en cubos.", "Volcá el batido de huevos.", "Tapá con la segunda masa.", "Horneá a 180°C por 30 minutos."] },
        { title: "Tarta caprese", ingredients: [["Tapa de tarta", "1", "unidad", nil], ["Tomate", "4", "unidad", "en rodajas"], ["Queso mozzarella", "250", "g", "en rodajas"], ["Albahaca", "10", "hojas", nil], ["Aceite de oliva", "2", "cucharada", nil], ["Huevo", "2", "unidad", nil], ["Crema de leche", "100", "ml", nil]], prep: 10, cook: 30, servings: 6, steps: ["Forré la tartera con la masa y pinchá.", "Alterná rodajas de tomate y mozzarella.", "Distribuí las hojas de albahaca.", "Batí los huevos con la crema y volcá encima.", "Rociá con aceite de oliva.", "Horneá a 180°C por 25-30 minutos."] },
        { title: "Tarta de atún y tomate", ingredients: [["Tapa de tarta", "1", "unidad", nil], ["Atún en lata", "2", "unidad", "escurridos"], ["Tomate", "2", "unidad", "en rodajas"], ["Cebolla", "1", "unidad", "en aros"], ["Huevo", "3", "unidad", nil], ["Crema de leche", "200", "ml", nil], ["Queso rallado", "3", "cucharada", nil]], prep: 10, cook: 30, servings: 6, steps: ["Forré la tartera y pinchá la base.", "Distribuí el atún desmenuzado.", "Agregá la cebolla en aros y las rodajas de tomate.", "Batí los huevos con crema y volcá.", "Espolvoreá con queso rallado.", "Horneá a 180°C por 30 minutos."] },
        { title: "Tarta pascualina de espinaca", ingredients: [["Tapa de tarta", "2", "unidad", nil], ["Espinaca", "500", "g", "cocida y escurrida"], ["Ricota", "300", "g", nil], ["Huevo", "5", "unidad", nil], ["Cebolla", "1", "unidad", "picada"], ["Nuez moscada", "1", "pizca", nil], ["Sal", "1", "pizca", nil]], prep: 20, cook: 40, servings: 8, steps: ["Forré la tartera con una tapa.", "Rehogá la cebolla y mezclala con la espinaca escurrida.", "Agregá la ricota, 2 huevos batidos, nuez moscada y sal.", "Volcá el relleno en la tartera.", "Hacé 3 huecos y rompé un huevo entero en cada uno.", "Tapá con la segunda masa y sellá los bordes.", "Pincelá con huevo batido y horneá a 180°C por 35-40 minutos."] },
      ],
      asado: [
        { title: "Asado de tira a la parrilla", ingredients: [["Asado de tira", "2", "kg", nil], ["Sal gruesa", "2", "cucharada", nil], ["Limón", "1", "unidad", nil], ["Chimichurri", "4", "cucharada", nil]], prep: 5, cook: 90, servings: 6, steps: ["Sacá la carne de la heladera 30 minutos antes.", "Encendé el fuego y esperá a tener buenas brasas.", "Poné las tiras del lado del hueso primero.", "Cocinás a fuego medio sin apurar, unos 40 minutos de ese lado.", "Dalo vuelta, salá con sal gruesa.", "Cociná otros 30-40 minutos.", "Servilo con chimichurri y limón."] },
        { title: "Vacío a la parrilla", ingredients: [["Vacío", "2", "kg", nil], ["Sal gruesa", "2", "cucharada", nil], ["Chimichurri", "4", "cucharada", nil]], prep: 5, cook: 120, servings: 8, steps: ["Sacá el vacío de la heladera 1 hora antes.", "Preparé buenas brasas, fuego medio.", "Poné el vacío con la grasa hacia abajo.", "Cociná tapado 1 hora sin tocar.", "Dalo vuelta, salá y cociná otros 40-50 minutos.", "Dejalo reposar 10 minutos antes de cortar.", "Cortá en contra de la fibra y servilo con chimichurri."] },
        { title: "Entraña a la parrilla", ingredients: [["Entraña", "1", "kg", nil], ["Sal gruesa", "1", "cucharada", nil], ["Limón", "2", "unidad", nil], ["Chimichurri", "3", "cucharada", nil]], prep: 5, cook: 15, servings: 4, steps: ["La entraña se hace rápido, necesitás buenas brasas fuertes.", "Poné la entraña del lado de la membrana.", "Cociná 5-7 minutos de ese lado.", "Dalo vuelta, salá y cociná 5 minutos más.", "Tiene que quedar jugosa por dentro.", "Cortá en tiras y servilo con limón y chimichurri."] },
        { title: "Chorizo a la pomarola", ingredients: [["Chorizo", "6", "unidad", nil], ["Tomate", "4", "unidad", "en cubos"], ["Cebolla", "1", "unidad", "en aros"], ["Morrón rojo", "1", "unidad", "en tiras"], ["Orégano", "1", "cucharadita", nil], ["Pan francés", "6", "unidad", nil]], prep: 5, cook: 30, servings: 6, steps: ["Hacé los chorizos a la parrilla a fuego medio.", "Mientras, preparé la pomarola: rehogá la cebolla y el morrón.", "Agregá el tomate en cubos y cociná 15 minutos.", "Condimentá con orégano y sal.", "Armá los choripanes en el pan francés.", "Cubrí con la pomarola casera."] },
        { title: "Pollo a la parrilla con limón", ingredients: [["Pollo", "1", "unidad", "cortado al medio"], ["Limón", "2", "unidad", nil], ["Ajo", "4", "diente", "picados"], ["Orégano", "1", "cucharada", nil], ["Aceite de oliva", "3", "cucharada", nil], ["Sal gruesa", "1", "cucharada", nil]], prep: 15, cook: 60, servings: 4, steps: ["Abrí el pollo al medio tipo mariposa.", "Hacé una marinada con limón, ajo, orégano y aceite.", "Untá bien el pollo y dejalo marinar 30 minutos.", "Poné el pollo del lado de la piel sobre la parrilla a fuego bajo.", "Cociná tapado 30 minutos.", "Dalo vuelta y cociná otros 25-30 minutos.", "Salá al final y dejalo reposar antes de servir."] },
      ],
      guisos: [
        { title: "Guiso de lentejas", ingredients: [["Lentejas", "400", "g", nil], ["Chorizo colorado", "2", "unidad", "en rodajas"], ["Papa", "2", "unidad", "en cubos"], ["Zanahoria", "2", "unidad", "en rodajas"], ["Cebolla", "1", "unidad", "picada"], ["Ajo", "2", "diente", "picados"], ["Tomate", "2", "unidad", "picados"], ["Caldo de verduras", "1", "l", nil], ["Pimentón dulce", "1", "cucharadita", nil], ["Comino", "1", "cucharadita", nil], ["Laurel", "2", "hojas", nil]], prep: 15, cook: 45, servings: 6, steps: ["Rehogá la cebolla y el ajo en una olla grande.", "Agregá la zanahoria y el chorizo colorado en rodajas.", "Sumá el tomate, pimentón y comino.", "Incorporá las lentejas (no hace falta remojarlas) y las papas.", "Cubrí con el caldo y agregá el laurel.", "Cociná a fuego bajo 40-45 minutos.", "Tiene que quedar espeso y con las lentejas tiernas."] },
        { title: "Locro", ingredients: [["Maíz blanco", "500", "g", "remojado 12 horas"], ["Porotos", "200", "g", "remojados"], ["Falda", "500", "g", "en trozos"], ["Chorizo colorado", "2", "unidad", nil], ["Panceta", "200", "g", "en cubos"], ["Zapallo", "500", "g", "en cubos"], ["Cebolla", "2", "unidad", "picadas"], ["Cebolla de verdeo", "2", "unidad", "picadas"], ["Pimentón dulce", "1", "cucharada", nil], ["Comino", "1", "cucharadita", nil]], prep: 30, cook: 180, servings: 10, steps: ["Remojá el maíz y los porotos la noche anterior.", "En una olla grande, sellá la falda y la panceta.", "Agregá la cebolla y rehogá.", "Sumá el maíz escurrido y cubrí con agua.", "Cociná a fuego bajo 2 horas.", "Agregá los porotos, el zapallo y el chorizo.", "Cociná 1 hora más hasta que todo esté tierno.", "Servilo con la salsa de cebolla de verdeo, ají y pimentón."] },
        { title: "Guiso de fideos con carne", ingredients: [["Fideos tirabuzón", "400", "g", nil], ["Carne picada especial", "300", "g", nil], ["Tomate", "3", "unidad", "picados"], ["Cebolla", "1", "unidad", "picada"], ["Morrón rojo", "1", "unidad", "picado"], ["Ajo", "2", "diente", nil], ["Caldo de carne", "500", "ml", nil], ["Pimentón dulce", "1", "cucharadita", nil]], prep: 10, cook: 30, servings: 6, steps: ["Rehogá la cebolla, ajo y morrón.", "Agregá la carne picada y dorala.", "Sumá los tomates y el pimentón.", "Cociná 10 minutos hasta que los tomates se deshagan.", "Agregá los fideos crudos y el caldo.", "Cociná tapado a fuego bajo hasta que los fideos estén al dente.", "Si hace falta, agregá más caldo."] },
        { title: "Carbonada criolla", ingredients: [["Carne para guiso", "500", "g", "en cubos"], ["Zapallo", "400", "g", "en cubos"], ["Papa", "2", "unidad", "en cubos"], ["Batata", "1", "unidad", "en cubos"], ["Choclo", "2", "unidad", "desgranados"], ["Tomate", "2", "unidad", "picados"], ["Cebolla", "1", "unidad", "picada"], ["Durazno", "2", "unidad", "en mitades"], ["Caldo de carne", "500", "ml", nil]], prep: 20, cook: 60, servings: 6, steps: ["Sellá la carne en cubos en una olla.", "Retirala y rehogá la cebolla.", "Agregá el tomate y cociná 5 minutos.", "Volvé a poner la carne y sumá el caldo.", "Cociná 30 minutos a fuego bajo.", "Agregá papa, batata, zapallo y choclo.", "Cociná 20 minutos más.", "Sumá los duraznos los últimos 5 minutos."] },
      ],
      sopas: [
        { title: "Sopa crema de zapallo", ingredients: [["Zapallo", "1", "kg", "en cubos"], ["Cebolla", "1", "unidad", "picada"], ["Caldo de verduras", "750", "ml", nil], ["Crema de leche", "100", "ml", nil], ["Manteca", "1", "cucharada", nil], ["Nuez moscada", "1", "pizca", nil]], prep: 10, cook: 30, servings: 6, steps: ["Rehogá la cebolla en manteca.", "Agregá el zapallo en cubos.", "Cubrí con caldo y cociná hasta que esté tierno.", "Procesá todo con minipimer hasta que quede cremoso.", "Agregá la crema y nuez moscada.", "Serví caliente con crutones."] },
        { title: "Sopa de cebolla gratinada", ingredients: [["Cebolla", "6", "unidad", "en aros finos"], ["Manteca", "2", "cucharada", nil], ["Caldo de carne", "1", "l", nil], ["Vino tinto", "100", "ml", nil], ["Pan francés", "4", "rebanada", nil], ["Queso gruyère", "150", "g", "rallado"]], prep: 10, cook: 45, servings: 4, steps: ["Derretí la manteca y cociná las cebollas a fuego bajo 30 minutos.", "Tienen que quedar caramelizadas y bien doradas.", "Agregá el vino y dejá reducir.", "Sumá el caldo y cociná 10 minutos más.", "Serví en bowls aptos para horno.", "Poné una rebanada de pan y cubrí con queso.", "Gratinar en el horno hasta que el queso burbujee."] },
      ],
      pastas: [
        { title: "Ñoquis de papa", ingredients: [["Papa", "1", "kg", nil], ["Harina 000", "300", "g", nil], ["Huevo", "1", "unidad", nil], ["Sal", "1", "cucharadita", nil], ["Nuez moscada", "1", "pizca", nil]], prep: 30, cook: 5, servings: 4, steps: ["Herví las papas con cáscara hasta que estén tiernas.", "Pelalas calientes y hacé un puré sin grumos.", "Agregá el huevo, la sal y nuez moscada.", "Incorporá la harina de a poco sin amasar de más.", "Formá rollitos y cortá en trocitos.", "Marcarlos con un tenedor.", "Hervílos en agua con sal, están listos cuando flotan."] },
        { title: "Tallarines con salsa bolognesa", ingredients: [["Tallarines", "500", "g", nil], ["Carne picada especial", "400", "g", nil], ["Tomate", "4", "unidad", "picados"], ["Cebolla", "1", "unidad", "picada"], ["Zanahoria", "1", "unidad", "rallada"], ["Ajo", "2", "diente", nil], ["Vino tinto", "100", "ml", nil], ["Orégano", "1", "cucharadita", nil], ["Laurel", "1", "hoja", nil]], prep: 15, cook: 45, servings: 4, steps: ["Rehogá cebolla, ajo y zanahoria rallada.", "Agregá la carne picada y dorala bien.", "Sumá el vino y dejá evaporar.", "Incorporá los tomates, orégano y laurel.", "Cociná a fuego bajo 30-40 minutos.", "Herví los tallarines al dente.", "Servilo con la bolognesa encima y queso rallado."] },
        { title: "Sorrentinos de jamón y queso", ingredients: [["Harina 000", "400", "g", nil], ["Huevo", "3", "unidad", nil], ["Jamón cocido", "200", "g", "picado"], ["Queso mozzarella", "200", "g", "en cubos"], ["Ricota", "100", "g", nil], ["Nuez moscada", "1", "pizca", nil]], prep: 45, cook: 5, servings: 4, steps: ["Hacé la masa con harina, huevos y un poco de agua.", "Dejala descansar 30 minutos.", "Mezclá el jamón, mozzarella, ricota y nuez moscada para el relleno.", "Estirá la masa finita.", "Poné bolitas de relleno y cortá con cortante redondo.", "Cerrá bien los bordes.", "Herví en agua con sal 3-4 minutos."] },
        { title: "Fideos con pesto argentino", ingredients: [["Fideos tirabuzón", "500", "g", nil], ["Albahaca", "2", "taza", "hojas frescas"], ["Ajo", "2", "diente", nil], ["Queso rallado", "4", "cucharada", nil], ["Nuez", "50", "g", nil], ["Aceite de oliva", "100", "ml", nil], ["Sal", "1", "pizca", nil]], prep: 10, cook: 10, servings: 4, steps: ["Procesá la albahaca con ajo, nueces y aceite de oliva.", "Agregá el queso rallado y sal.", "Herví los fideos al dente.", "Antes de colar, reservá una taza del agua de cocción.", "Mezclá los fideos con el pesto y un poco del agua.", "Servilo enseguida con más queso rallado."] },
        { title: "Ravioles de verdura con salsa fileto", ingredients: [["Harina 000", "400", "g", nil], ["Huevo", "3", "unidad", nil], ["Espinaca", "300", "g", "cocida"], ["Ricota", "250", "g", nil], ["Nuez moscada", "1", "pizca", nil], ["Tomate", "6", "unidad", "pelados"], ["Cebolla", "1", "unidad", nil], ["Ajo", "2", "diente", nil], ["Albahaca", "6", "hojas", nil]], prep: 60, cook: 20, servings: 4, steps: ["Hacé la masa de ravioles con harina y huevos.", "Mezclá espinaca bien escurrida con ricota y nuez moscada.", "Estirá la masa y poné bolitas de relleno.", "Tapá con otra capa de masa y cortá los ravioles.", "Para la fileto: rehogá cebolla y ajo, agregá tomate.", "Cociná 20 minutos y agregá albahaca.", "Herví los ravioles y servilos con la fileto."] },
      ],
      milanesas: [
        { title: "Milanesa napolitana", ingredients: [["Bife de nalga", "4", "unidad", "finos"], ["Huevo", "2", "unidad", nil], ["Pan rallado", "200", "g", nil], ["Salsa de tomate", "200", "ml", nil], ["Jamón cocido", "4", "feta", nil], ["Queso mozzarella", "200", "g", "en fetas"], ["Orégano", "1", "cucharadita", nil]], prep: 15, cook: 20, servings: 4, steps: ["Pasá los bifes por huevo batido y pan rallado.", "Freílos en aceite caliente hasta que estén dorados.", "Ponelos en una fuente para horno.", "Cubrí cada milanesa con salsa de tomate.", "Agregá una feta de jamón y una de mozzarella.", "Espolvoreá con orégano.", "Gratinar en el horno hasta que el queso se derrita."] },
        { title: "Milanesa de pollo al horno", ingredients: [["Pechuga de pollo", "4", "unidad", "fileteadas"], ["Huevo", "2", "unidad", nil], ["Pan rallado", "200", "g", nil], ["Ajo", "1", "diente", "picado"], ["Perejil", "2", "cucharada", "picado"], ["Aceite de oliva", "2", "cucharada", nil]], prep: 15, cook: 25, servings: 4, steps: ["Aplastá las pechugas para que queden parejas.", "Batí los huevos con ajo y perejil.", "Pasá por huevo y después por pan rallado.", "Ponelas en una placa con papel manteca.", "Rocialas con aceite de oliva.", "Horneá a 200°C por 20-25 minutos dándolas vuelta a mitad."] },
        { title: "Milanesa de berenjena", ingredients: [["Berenjena", "2", "unidad", "en rodajas gruesas"], ["Huevo", "2", "unidad", nil], ["Pan rallado", "200", "g", nil], ["Queso rallado", "3", "cucharada", nil], ["Orégano", "1", "cucharadita", nil], ["Aceite de girasol", "300", "ml", "para freír"]], prep: 15, cook: 15, servings: 4, steps: ["Cortá las berenjenas en rodajas de 1 cm.", "Salalas y dejalas 15 minutos para que larguen el amargor.", "Secalas con papel.", "Pasalas por huevo y por pan rallado mezclado con queso y orégano.", "Freílas en aceite caliente hasta que estén doradas.", "Servilas con limón o salsa fileto."] },
      ],
      carnes: [
        { title: "Bife de chorizo a la plancha", ingredients: [["Bife de chorizo", "4", "unidad", nil], ["Sal gruesa", "1", "cucharadita", nil], ["Pimienta negra", "1", "pizca", nil], ["Manteca", "1", "cucharada", nil]], prep: 5, cook: 12, servings: 4, steps: ["Sacá los bifes de la heladera 30 minutos antes.", "Calentá bien la plancha o sartén.", "Salá los bifes y ponelos en la plancha caliente.", "Cociná 4-5 minutos de cada lado para punto medio.", "Al dar vuelta, agregá un poco de manteca.", "Dejá reposar 3 minutos antes de servir."] },
        { title: "Peceto al horno con papas", ingredients: [["Peceto", "1", "kg", nil], ["Papa", "6", "unidad", "en cuartos"], ["Cebolla", "2", "unidad", "en cuartos"], ["Ajo", "4", "diente", nil], ["Romero", "2", "rama", nil], ["Aceite de oliva", "3", "cucharada", nil], ["Vino blanco", "150", "ml", nil]], prep: 15, cook: 60, servings: 6, steps: ["Sellá el peceto en una sartén con aceite bien caliente.", "Ponelo en una asadera con las papas y cebollas.", "Agregá los ajos, romero y vino blanco.", "Salpimentá todo.", "Horneá a 180°C por 50-60 minutos.", "Dejá reposar 10 minutos antes de cortar en rodajas."] },
        { title: "Colita de cuadril al horno", ingredients: [["Colita de cuadril", "1.5", "kg", nil], ["Morrón rojo", "2", "unidad", "en tiras"], ["Cebolla", "2", "unidad", "en aros"], ["Tomate", "3", "unidad", "en rodajas"], ["Ajo", "3", "diente", nil], ["Orégano", "1", "cucharada", nil], ["Vino tinto", "200", "ml", nil]], prep: 15, cook: 90, servings: 6, steps: ["Salpimentá la colita de cuadril.", "Sellala en una olla o asadera a fuego fuerte.", "Armá una cama de cebollas, morrones y tomates.", "Poné la carne encima y agregá ajo y orégano.", "Volcá el vino tinto.", "Tapá con papel aluminio y horneá a 180°C por 1 hora y media.", "Cortá en rodajas y serví con las verduras."] },
      ],
      pescados: [
        { title: "Merluza a la romana", ingredients: [["Merluza", "600", "g", "en filetes"], ["Harina 000", "150", "g", nil], ["Huevo", "2", "unidad", nil], ["Cerveza rubia", "100", "ml", nil], ["Limón", "2", "unidad", nil], ["Aceite de girasol", "500", "ml", "para freír"], ["Sal", "1", "pizca", nil]], prep: 10, cook: 15, servings: 4, steps: ["Secá los filetes de merluza y salpimentalos.", "Preparé el batido con harina, huevos, cerveza y sal.", "Calentá el aceite a 180°C.", "Pasá los filetes por el batido.", "Freílos hasta que estén dorados y crocantes.", "Escurrilos sobre papel absorbente.", "Servilos con gajos de limón."] },
        { title: "Salmón al horno con vegetales", ingredients: [["Salmón rosado", "4", "unidad", "filetes"], ["Zapallito verde", "2", "unidad", "en rodajas"], ["Tomate cherry", "200", "g", nil], ["Aceite de oliva", "3", "cucharada", nil], ["Limón", "1", "unidad", nil], ["Eneldo", "1", "cucharada", "fresco"]], prep: 10, cook: 20, servings: 4, steps: ["Precalentá el horno a 200°C.", "Poné los filetes de salmón en una placa.", "Distribuí los zapallitos y tomates cherry alrededor.", "Rociá con aceite y jugo de limón.", "Salpimentá y agregá el eneldo.", "Horneá 18-20 minutos.", "El salmón tiene que estar rosado por dentro."] },
      ],
      pollo: [
        { title: "Pollo al verdeo con puré", ingredients: [["Muslo de pollo", "8", "unidad", nil], ["Cebolla de verdeo", "6", "unidad", "picadas"], ["Crema de leche", "200", "ml", nil], ["Caldo de pollo", "200", "ml", nil], ["Papa", "1", "kg", nil], ["Manteca", "2", "cucharada", nil], ["Leche", "100", "ml", nil]], prep: 15, cook: 40, servings: 4, steps: ["Salpimentá los muslos y doralos en una sartén.", "Retiralos y rehogá la cebolla de verdeo.", "Volvé a poner el pollo y agregá el caldo.", "Tapá y cociná 25 minutos a fuego bajo.", "Agregá la crema y cociná 5 minutos más.", "Para el puré: herví las papas, pisalas con manteca y leche.", "Servilo junto."] },
        { title: "Pollo a la cacerola con verduras", ingredients: [["Pollo", "1", "unidad", "trozado"], ["Papa", "3", "unidad", "en cuartos"], ["Zanahoria", "2", "unidad", "en rodajas"], ["Cebolla", "2", "unidad", "en cuartos"], ["Morrón rojo", "1", "unidad", "en tiras"], ["Vino blanco", "150", "ml", nil], ["Ajo", "3", "diente", nil], ["Orégano", "1", "cucharadita", nil]], prep: 15, cook: 50, servings: 6, steps: ["Salpimentá los trozos de pollo.", "Doralos en una cacerola con aceite.", "Retirá y rehogá las cebollas y ajo.", "Volvé a poner el pollo y agregá las verduras.", "Volcá el vino y un vaso de agua.", "Condimentá con orégano.", "Tapá y cociná a fuego bajo 45 minutos."] },
        { title: "Suprema rellena de jamón y queso", ingredients: [["Pechuga de pollo", "4", "unidad", nil], ["Jamón cocido", "4", "feta", nil], ["Queso mozzarella", "4", "feta", nil], ["Huevo", "2", "unidad", nil], ["Pan rallado", "200", "g", nil]], prep: 20, cook: 25, servings: 4, steps: ["Abrí las pechugas al medio tipo libro.", "Rellenó con una feta de jamón y una de queso.", "Cerralas con escarbadientes.", "Pasalas por huevo batido y pan rallado.", "Horneá a 180°C por 25 minutos.", "Servilo con ensalada mixta."] },
      ],
      cerdo: [
        { title: "Bondiola al horno con miel y mostaza", ingredients: [["Bondiola de cerdo", "1.5", "kg", nil], ["Miel", "3", "cucharada", nil], ["Mostaza", "3", "cucharada", nil], ["Ajo", "4", "diente", "picados"], ["Romero", "2", "rama", nil], ["Sal", "1", "cucharadita", nil]], prep: 10, cook: 120, servings: 6, steps: ["Hacele cortes al lomo de cerdo y metele el ajo.", "Mezclá miel con mostaza y untá toda la bondiola.", "Ponele las ramas de romero encima.", "Envolvelo en papel aluminio.", "Horneá a 160°C por 2 horas.", "Abrí el aluminio los últimos 20 minutos para que se dore.", "Dejá reposar y cortá en rodajas."] },
        { title: "Matambre de cerdo a la pizza", ingredients: [["Matambre de cerdo", "1", "kg", nil], ["Salsa de tomate", "200", "ml", nil], ["Queso mozzarella", "200", "g", "en fetas"], ["Orégano", "1", "cucharadita", nil], ["Aceitunas verdes", "50", "g", nil]], prep: 10, cook: 60, servings: 6, steps: ["Horneá el matambre a 180°C por 40 minutos.", "Sacalo y cubrilo con salsa de tomate.", "Agregá las fetas de mozzarella y aceitunas.", "Espolvoreá con orégano.", "Volvé al horno 15 minutos hasta que gratine.", "Cortá en porciones y servilo."] },
        { title: "Costillitas de cerdo agridulces", ingredients: [["Costillitas de cerdo", "1", "kg", nil], ["Salsa de soja", "3", "cucharada", nil], ["Miel", "3", "cucharada", nil], ["Ketchup", "2", "cucharada", nil], ["Ajo", "2", "diente", "picados"], ["Jengibre", "1", "cucharadita", "rallado"]], prep: 15, cook: 90, servings: 4, steps: ["Mezclá la salsa de soja, miel, ketchup, ajo y jengibre.", "Mariná las costillitas al menos 2 horas.", "Envolvelas en papel aluminio.", "Horneá a 160°C por 1 hora.", "Abrí el aluminio y bañalas con más marinada.", "Subí el horno a 200°C y dorá 15 minutos más."] },
      ],
      ensaladas: [
        { title: "Ensalada César con pollo", ingredients: [["Lechuga", "1", "unidad", nil], ["Pechuga de pollo", "2", "unidad", "grilladas"], ["Queso parmesano", "50", "g", "en escamas"], ["Pan francés", "2", "rebanada", "en cubos"], ["Mayonesa", "2", "cucharada", nil], ["Limón", "1", "unidad", "jugo"], ["Ajo", "1", "diente", "picado"], ["Aceite de oliva", "2", "cucharada", nil]], prep: 15, cook: 10, servings: 4, steps: ["Cortá el pan en cubos y tostalos en el horno con aceite.", "Grillá las pechugas y cortalas en tiras.", "Lavá y cortá la lechuga.", "Hacé el aderezo mezclando mayonesa, limón, ajo y aceite.", "Armá la ensalada con la lechuga como base.", "Agregá el pollo, crutones y escamas de parmesano.", "Condimentá con el aderezo César."] },
        { title: "Ensalada rusa", ingredients: [["Papa", "3", "unidad", "hervidas en cubos"], ["Zanahoria", "2", "unidad", "hervidas en cubos"], ["Arvejas", "200", "g", "cocidas"], ["Huevo", "3", "unidad", "duros picados"], ["Mayonesa", "4", "cucharada", nil], ["Sal", "1", "pizca", nil]], prep: 20, cook: 20, servings: 6, steps: ["Herví las papas y zanahorias hasta que estén tiernas.", "Cortá todo en cubos parejos.", "Mezclá con las arvejas y los huevos duros picados.", "Agregá la mayonesa y sal.", "Mezclá con cuidado para no deshacer los cubos.", "Servila fría."] },
      ],
      acompañamientos: [
        { title: "Puré de papas cremoso", ingredients: [["Papa", "1", "kg", nil], ["Manteca", "50", "g", nil], ["Leche", "150", "ml", "tibia"], ["Nuez moscada", "1", "pizca", nil], ["Sal", "1", "cucharadita", nil]], prep: 10, cook: 25, servings: 6, steps: ["Pelá y cortá las papas en trozos.", "Hervílas en agua con sal hasta que estén tiernas.", "Escurrílas bien.", "Pisalas calientes con manteca.", "Agregá la leche tibia de a poco.", "Condimentá con sal y nuez moscada.", "Tiene que quedar cremoso y sin grumos."] },
        { title: "Papas rústicas al horno", ingredients: [["Papa", "1", "kg", "con cáscara en gajos"], ["Aceite de oliva", "3", "cucharada", nil], ["Romero", "1", "cucharada", "fresco"], ["Ajo", "3", "diente", "con cáscara"], ["Sal gruesa", "1", "cucharadita", nil], ["Pimentón ahumado", "1", "cucharadita", nil]], prep: 10, cook: 40, servings: 6, steps: ["Precalentá el horno a 200°C.", "Cortá las papas en gajos con cáscara.", "Mezclalas con aceite, romero, ajo, sal y pimentón.", "Distribuilas en una placa sin apilar.", "Horneá 35-40 minutos dándolas vuelta a la mitad.", "Tienen que quedar doradas y crocantes por fuera."] },
      ],
      salsas: [
        { title: "Chimichurri", ingredients: [["Perejil", "1", "taza", "picado fino"], ["Ajo", "4", "diente", "picados"], ["Orégano", "1", "cucharada", "seco"], ["Ají molido", "1", "cucharadita", nil], ["Vinagre de vino", "3", "cucharada", nil], ["Aceite de oliva", "100", "ml", nil], ["Sal", "1", "cucharadita", nil]], prep: 10, cook: 0, servings: 8, steps: ["Picá el perejil bien fino.", "Mezclalo con el ajo picado, orégano y ají molido.", "Agregá el vinagre y el aceite.", "Condimentá con sal.", "Dejalo reposar al menos 1 hora antes de usar.", "Es ideal para acompañar carnes a la parrilla."] },
        { title: "Salsa criolla", ingredients: [["Tomate", "3", "unidad", "picados"], ["Cebolla", "2", "unidad", "picadas"], ["Morrón rojo", "1", "unidad", "picado"], ["Morrón verde", "1", "unidad", "picado"], ["Vinagre de vino", "2", "cucharada", nil], ["Aceite de oliva", "3", "cucharada", nil], ["Orégano", "1", "cucharadita", nil]], prep: 15, cook: 0, servings: 8, steps: ["Picá todos los vegetales en cubos chicos y parejos.", "Mezclalos en un bowl.", "Condimentá con vinagre, aceite, orégano y sal.", "Dejá macerar al menos 30 minutos.", "Servila para acompañar asado o empanadas."] },
      ],
      panificados: [
        { title: "Pan casero", ingredients: [["Harina 000", "1", "kg", nil], ["Levadura fresca", "25", "g", nil], ["Agua", "550", "ml", "tibia"], ["Sal", "1", "cucharada", nil], ["Azúcar", "1", "cucharadita", nil]], prep: 30, cook: 35, servings: 10, steps: ["Disolvé la levadura con agua tibia y azúcar.", "Mezclá la harina con la sal.", "Hacé un hueco y volcá la levadura disuelta.", "Amasá 10 minutos hasta que la masa esté lisa.", "Dejá levar tapada 1 hora.", "Desgasá, formá el pan y poné en molde.", "Dejá levar 30 minutos más.", "Horneá a 200°C por 30-35 minutos."] },
        { title: "Medialunas de manteca", ingredients: [["Harina 000", "500", "g", nil], ["Manteca", "200", "g", "fría"], ["Leche", "150", "ml", nil], ["Levadura fresca", "20", "g", nil], ["Azúcar", "80", "g", nil], ["Huevo", "2", "unidad", nil], ["Esencia de vainilla", "1", "cucharadita", nil]], prep: 60, cook: 15, servings: 12, steps: ["Disolvé la levadura en leche tibia con una cucharada de azúcar.", "Mezclá harina con azúcar y hacé un hueco.", "Agregá huevos, leche con levadura y vainilla.", "Amasá y dejá descansar 20 minutos.", "Estirá, poné láminas de manteca y hacé 3 dobleces.", "Dejá descansar entre cada doblez en la heladera.", "Estirá, cortá triángulos y enrollá.", "Dejá levar 40 minutos y horneá a 190°C por 12-15 minutos."] },
      ],
      pizzas: [
        { title: "Pizza a la piedra con muzzarella", ingredients: [["Harina 000", "500", "g", nil], ["Levadura fresca", "15", "g", nil], ["Agua", "300", "ml", nil], ["Aceite de oliva", "2", "cucharada", nil], ["Sal", "1", "cucharadita", nil], ["Salsa de tomate", "200", "ml", nil], ["Queso mozzarella", "300", "g", nil], ["Orégano", "1", "cucharadita", nil]], prep: 90, cook: 10, servings: 4, steps: ["Disolvé la levadura en agua tibia.", "Mezclá con harina, sal y aceite.", "Amasá 10 minutos y dejá levar 1 hora.", "Estirá la masa bien finita.", "Cociná un par de minutos en horno bien fuerte (250°C).", "Sacá, poné salsa, mozzarella y orégano.", "Volvé al horno hasta que el queso se derrita y burbuejee."] },
        { title: "Fugazzeta rellena", ingredients: [["Harina 000", "500", "g", nil], ["Levadura fresca", "15", "g", nil], ["Agua", "300", "ml", nil], ["Cebolla", "6", "unidad", "en aros"], ["Queso mozzarella", "400", "g", nil], ["Aceite de oliva", "3", "cucharada", nil], ["Sal", "1", "cucharadita", nil]], prep: 90, cook: 25, servings: 6, steps: ["Preparé la masa de pizza y dejala levar.", "Dividila en 2 bollos.", "Estirá una parte y poné en la pizzera.", "Cubrí con mozzarella.", "Tapá con la segunda masa y sellá los bordes.", "Cubrí con aros de cebolla abundante.", "Rociá con aceite de oliva.", "Horneá a 220°C por 20-25 minutos."] },
      ],
      sandwiches: [
        { title: "Lomito completo", ingredients: [["Lomo de vaca", "400", "g", "en bifes finos"], ["Pan de hamburguesa", "4", "unidad", nil], ["Lechuga", "4", "hojas", nil], ["Tomate", "1", "unidad", "en rodajas"], ["Huevo", "4", "unidad", "fritos"], ["Jamón cocido", "4", "feta", nil], ["Queso mozzarella", "4", "feta", nil]], prep: 10, cook: 15, servings: 4, steps: ["Salpimentá los bifes de lomo y hacelos a la plancha.", "Tostá los panes.", "Armá el sándwich: pan, lechuga, lomo, jamón.", "Agregá queso, tomate y huevo frito.", "Cerrar y servir bien caliente."] },
        { title: "Tostado de jamón y queso", ingredients: [["Pan de miga", "8", "rebanada", nil], ["Jamón cocido", "8", "feta", nil], ["Queso mozzarella", "8", "feta", nil]], prep: 2, cook: 5, servings: 4, steps: ["Armá los sándwiches con dos fetas de jamón y dos de queso.", "Cerralos.", "Tostalo en la tostadora o plancha.", "Cortalo al medio en diagonal.", "Servilo caliente."] },
      ],
      tortillas: [
        { title: "Tortilla de papas española", ingredients: [["Papa", "4", "unidad", "en rodajas finas"], ["Huevo", "6", "unidad", nil], ["Cebolla", "1", "unidad", "en aros"], ["Aceite de oliva", "150", "ml", nil], ["Sal", "1", "pizca", nil]], prep: 15, cook: 25, servings: 4, steps: ["Freí las papas en rodajas en aceite de oliva a fuego medio.", "Agregá la cebolla y cociná hasta que todo esté tierno.", "Escurrí el aceite.", "Batí los huevos con sal.", "Mezclá con las papas y cebollas.", "Volcá en una sartén y cociná a fuego bajo.", "Cuando esté firme, dala vuelta con un plato.", "Cociná del otro lado 3-4 minutos más."] },
      ],
      dulces: [
        { title: "Flan casero con dulce de leche", ingredients: [["Huevo", "6", "unidad", nil], ["Leche", "750", "ml", nil], ["Azúcar", "200", "g", nil], ["Esencia de vainilla", "1", "cucharadita", nil], ["Dulce de leche", "200", "g", nil]], prep: 15, cook: 50, servings: 8, steps: ["Hacé un caramelo con 150g de azúcar y volcalo en la flanera.", "Batí los huevos con el azúcar restante.", "Agregá la leche y vainilla.", "Volcá en la flanera caramelizada.", "Cociná a baño maría en el horno a 160°C por 50 minutos.", "Dejá enfriar y desmoldá.", "Servilo con dulce de leche y crema."] },
        { title: "Panqueques con dulce de leche", ingredients: [["Huevo", "2", "unidad", nil], ["Leche", "250", "ml", nil], ["Harina 000", "150", "g", nil], ["Manteca", "1", "cucharada", "derretida"], ["Dulce de leche", "300", "g", nil]], prep: 10, cook: 15, servings: 8, steps: ["Batí los huevos con la leche.", "Agregá la harina y la manteca derretida.", "Mezclá hasta que no queden grumos.", "Calentá una sartén antiadherente con un poquito de manteca.", "Volcá una cucharada de mezcla y girá la sartén.", "Cociná de ambos lados.", "Rellenó con dulce de leche y enrollá."] },
        { title: "Arroz con leche", ingredients: [["Arroz", "200", "g", nil], ["Leche", "1", "l", nil], ["Azúcar", "150", "g", nil], ["Canela en rama", "1", "unidad", nil], ["Cáscara de limón", "1", "tira", nil], ["Esencia de vainilla", "1", "cucharadita", nil]], prep: 5, cook: 40, servings: 6, steps: ["Herví el arroz en agua 5 minutos y escurrí.", "Poné el arroz con la leche, canela y cáscara de limón.", "Cociná a fuego bajo revolviendo seguido.", "Cuando espese, agregá el azúcar y vainilla.", "Seguí cocinando 10 minutos más.", "Sacá la canela y el limón.", "Servilo tibio o frío con canela espolvoreada."] },
        { title: "Chocotorta", ingredients: [["Galletitas de chocolate", "3", "paquete", nil], ["Dulce de leche", "400", "g", nil], ["Queso crema", "400", "g", nil], ["Café", "200", "ml", "frío"], ["Cacao amargo", "2", "cucharada", nil]], prep: 20, cook: 0, servings: 10, steps: ["Mezclá el dulce de leche con el queso crema.", "Mojá las galletitas en café frío.", "Armá una capa de galletitas en una fuente.", "Cubrí con la mezcla de dulce de leche.", "Repetí las capas.", "Espolvoreá cacao amargo arriba.", "Llevala a la heladera mínimo 4 horas antes de servir."] },
      ],
      tortas: [
        { title: "Torta de chocolate", ingredients: [["Harina 000", "250", "g", nil], ["Cacao amargo", "50", "g", nil], ["Huevo", "3", "unidad", nil], ["Azúcar", "250", "g", nil], ["Manteca", "125", "g", nil], ["Leche", "200", "ml", nil], ["Polvo de hornear", "2", "cucharadita", nil], ["Esencia de vainilla", "1", "cucharadita", nil]], prep: 15, cook: 35, servings: 10, steps: ["Precalentá el horno a 180°C.", "Mezclá harina, cacao y polvo de hornear.", "Batí manteca con azúcar hasta que esté cremoso.", "Agregá los huevos de a uno.", "Incorporá los secos alternando con la leche.", "Agregá vainilla.", "Volcá en molde enmantecado.", "Horneá 30-35 minutos."] },
        { title: "Rogel", ingredients: [["Harina 000", "500", "g", nil], ["Manteca", "200", "g", nil], ["Huevo", "4", "unidad", nil], ["Esencia de vainilla", "1", "cucharadita", nil], ["Dulce de leche", "1", "kg", nil], ["Clara de huevo", "4", "unidad", nil], ["Azúcar", "200", "g", nil]], prep: 60, cook: 60, servings: 12, steps: ["Hacé la masa con harina, manteca, yemas y vainilla.", "Dividí en 8-10 bollos.", "Estirá cada uno finito y cociná en horno a 180°C.", "Cada capa tarda unos 5-6 minutos.", "Armá el rogel intercalando capas con dulce de leche.", "Para el merengue: batí claras a nieve e incorporá azúcar.", "Cubrí el rogel con el merengue italiano.", "Dorá con soplete o en horno fuerte."] },
      ],
      galletitas: [
        { title: "Alfajores de maicena", ingredients: [["Maicena", "300", "g", nil], ["Harina 000", "200", "g", nil], ["Manteca", "200", "g", nil], ["Azúcar impalpable", "100", "g", nil], ["Huevo", "3", "unidad", "yemas"], ["Polvo de hornear", "1", "cucharadita", nil], ["Esencia de vainilla", "1", "cucharadita", nil], ["Dulce de leche", "300", "g", nil], ["Coco rallado", "100", "g", nil]], prep: 30, cook: 12, servings: 20, steps: ["Batí la manteca con el azúcar impalpable.", "Agregá las yemas y vainilla.", "Incorporá la maicena, harina y polvo de hornear.", "Estirá la masa y cortá círculos.", "Horneá a 160°C por 10-12 minutos.", "Dejá enfriar y rellenó con dulce de leche.", "Pasá los bordes por coco rallado."] },
        { title: "Pepas de membrillo", ingredients: [["Harina 000", "300", "g", nil], ["Manteca", "150", "g", nil], ["Azúcar", "100", "g", nil], ["Huevo", "1", "unidad", nil], ["Esencia de vainilla", "1", "cucharadita", nil], ["Dulce de membrillo", "200", "g", nil]], prep: 20, cook: 12, servings: 15, steps: ["Batí manteca con azúcar.", "Agregá el huevo y vainilla.", "Incorporá la harina y formá la masa.", "Hacé bolitas y ponelas en una placa.", "Hacé un hueco en el centro de cada una.", "Rellenó con dulce de membrillo.", "Horneá a 180°C por 10-12 minutos."] },
      ],
      helados: [
        { title: "Helado de dulce de leche casero", ingredients: [["Crema de leche", "500", "ml", nil], ["Dulce de leche", "400", "g", nil], ["Leche", "200", "ml", nil], ["Esencia de vainilla", "1", "cucharadita", nil]], prep: 15, cook: 0, servings: 8, steps: ["Mezclá el dulce de leche con la leche hasta integrar.", "Batí la crema a medio punto.", "Incorporá la mezcla de dulce de leche y la vainilla.", "Volcá en un recipiente apto para freezer.", "Llevá al freezer.", "Cada 1 hora sacá y batí para romper cristales.", "Repetí 3-4 veces y dejá endurecer."] },
      ],
      budines: [
        { title: "Budín de pan", ingredients: [["Pan francés", "300", "g", "del día anterior"], ["Leche", "500", "ml", nil], ["Huevo", "3", "unidad", nil], ["Azúcar", "150", "g", nil], ["Esencia de vainilla", "1", "cucharadita", nil], ["Pasas de uva", "50", "g", nil], ["Dulce de leche", "4", "cucharada", nil]], prep: 20, cook: 45, servings: 8, steps: ["Cortá el pan en trozos y remojalo en leche tibia.", "Hacé un caramelo con 80g de azúcar y volcalo en el molde.", "Batí los huevos con el azúcar restante y vainilla.", "Mezclá con el pan remojado y las pasas de uva.", "Volcá en el molde caramelizado.", "Horneá a baño maría a 180°C por 40-45 minutos.", "Dejá enfriar, desmoldá y serví con dulce de leche."] },
        { title: "Budín de banana", ingredients: [["Banana", "3", "unidad", "maduras"], ["Harina 000", "200", "g", nil], ["Azúcar", "150", "g", nil], ["Huevo", "2", "unidad", nil], ["Manteca", "80", "g", nil], ["Polvo de hornear", "1", "cucharadita", nil], ["Nuez", "50", "g", "picadas"]], prep: 15, cook: 45, servings: 8, steps: ["Pisá las bananas con un tenedor.", "Batí manteca con azúcar.", "Agregá los huevos y las bananas.", "Incorporá harina con polvo de hornear.", "Agregá las nueces picadas.", "Volcá en molde de budín enmantecado.", "Horneá a 180°C por 40-45 minutos."] },
      ],
      alfajores: [
        { title: "Alfajores de chocolate", ingredients: [["Harina 000", "250", "g", nil], ["Cacao amargo", "30", "g", nil], ["Manteca", "150", "g", nil], ["Azúcar", "100", "g", nil], ["Huevo", "2", "unidad", "yemas"], ["Dulce de leche", "300", "g", nil], ["Chocolate semiamargo", "200", "g", nil]], prep: 30, cook: 12, servings: 15, steps: ["Batí manteca con azúcar.", "Agregá las yemas.", "Incorporá harina y cacao.", "Estirá y cortá círculos.", "Horneá a 170°C por 10-12 minutos.", "Dejá enfriar y rellenó con dulce de leche.", "Bañá en chocolate derretido."] },
      ],
      mermeladas: [
        { title: "Dulce de leche casero", ingredients: [["Leche", "2", "l", nil], ["Azúcar", "500", "g", nil], ["Esencia de vainilla", "1", "cucharadita", nil], ["Bicarbonato de sodio", "1", "pizca", nil]], prep: 5, cook: 180, servings: 20, steps: ["Poné la leche con el azúcar y bicarbonato en una olla grande.", "Llevá a hervor revolviendo.", "Bajá el fuego al mínimo.", "Cociná revolviendo cada tanto durante 2-3 horas.", "Cuando tome color marrón y espese, agregá vainilla.", "Dejá enfriar y guardá en frasco."] },
      ],
      bebidas: [
        { title: "Licuado de banana y dulce de leche", ingredients: [["Banana", "2", "unidad", nil], ["Leche", "400", "ml", nil], ["Dulce de leche", "2", "cucharada", nil], ["Hielo", "4", "cubos", nil]], prep: 5, cook: 0, servings: 2, steps: ["Pelá las bananas y cortalas.", "Ponelas en la licuadora con la leche.", "Agregá el dulce de leche y el hielo.", "Licuá hasta que esté cremoso.", "Serví enseguida."] },
      ],
      rapidas: [
        { title: "Revuelto gramajo", ingredients: [["Papa", "3", "unidad", "en bastones finos"], ["Jamón cocido", "200", "g", "en tiras"], ["Huevo", "4", "unidad", nil], ["Cebolla", "1", "unidad", "picada"], ["Aceite de girasol", "200", "ml", nil], ["Arvejas", "100", "g", "cocidas"]], prep: 10, cook: 15, servings: 4, steps: ["Freí las papas en bastones hasta que estén doradas.", "En otra sartén, rehogá la cebolla y el jamón.", "Agregá las arvejas.", "Incorporá las papas fritas.", "Batí los huevos y volcalos encima.", "Revolveé hasta que el huevo cuaje pero quede cremoso."] },
        { title: "Tostado en sartén con tomate", ingredients: [["Pan lactal", "4", "rebanada", nil], ["Queso cremoso", "4", "feta", nil], ["Tomate", "1", "unidad", "en rodajas"], ["Jamón cocido", "4", "feta", nil], ["Manteca", "1", "cucharada", nil]], prep: 5, cook: 5, servings: 2, steps: ["Armá los sándwiches con jamón, queso y rodajas de tomate.", "Enmantecá la sartén.", "Tostá de ambos lados hasta que el queso se derrita.", "Cortá al medio y servilo caliente."] },
      ],
      economicas: [
        { title: "Fideos con manteca y queso", ingredients: [["Fideos tirabuzón", "500", "g", nil], ["Manteca", "3", "cucharada", nil], ["Queso rallado", "6", "cucharada", nil], ["Pimienta negra", "1", "pizca", nil]], prep: 2, cook: 10, servings: 4, steps: ["Herví los fideos al dente.", "Escurrilos y volvelos a la olla.", "Agregá la manteca y mezclá.", "Sumá el queso rallado y pimienta.", "Mezclá bien y servilo enseguida."] },
        { title: "Polenta con salsa", ingredients: [["Polenta", "300", "g", nil], ["Agua", "1", "l", nil], ["Salsa de tomate", "300", "ml", nil], ["Queso rallado", "4", "cucharada", nil], ["Sal", "1", "cucharadita", nil]], prep: 5, cook: 15, servings: 4, steps: ["Herví el agua con sal.", "Agregá la polenta en forma de lluvia revolviendo.", "Cociná revolviendo 10-15 minutos a fuego bajo.", "Serví la polenta en platos.", "Cubrí con salsa de tomate caliente.", "Espolvoreá con queso rallado."] },
      ],
      vegetariano: [
        { title: "Hamburguesas de lentejas", ingredients: [["Lentejas", "300", "g", "cocidas"], ["Cebolla", "1", "unidad", "picada"], ["Ajo", "1", "diente", nil], ["Pan rallado", "3", "cucharada", nil], ["Comino", "1", "cucharadita", nil], ["Huevo", "1", "unidad", nil]], prep: 15, cook: 10, servings: 4, steps: ["Procesá las lentejas pero dejá textura.", "Mezclá con cebolla rehogada, ajo, pan rallado y comino.", "Agregá el huevo para unir.", "Formá hamburguesas y llevalas a la heladera 30 minutos.", "Cocinalas en sartén con un poco de aceite.", "Servilas en pan con los toppings que quieras."] },
      ],
      desayunos: [
        { title: "Tostadas francesas", ingredients: [["Pan lactal", "6", "rebanada", nil], ["Huevo", "2", "unidad", nil], ["Leche", "100", "ml", nil], ["Canela", "1", "cucharadita", nil], ["Azúcar", "2", "cucharada", nil], ["Manteca", "2", "cucharada", nil]], prep: 5, cook: 10, servings: 3, steps: ["Batí los huevos con leche, canela y azúcar.", "Remojá cada rebanada de pan en la mezcla.", "Calentá manteca en una sartén.", "Cociná cada tostada hasta que esté dorada de ambos lados.", "Servilas con miel, frutas o dulce de leche."] },
        { title: "Scones de queso", ingredients: [["Harina 000", "300", "g", nil], ["Manteca", "80", "g", "fría en cubos"], ["Queso rallado", "100", "g", nil], ["Huevo", "1", "unidad", nil], ["Leche", "100", "ml", nil], ["Polvo de hornear", "1", "cucharada", nil], ["Sal", "1", "pizca", nil]], prep: 15, cook: 20, servings: 10, steps: ["Mezclá harina, polvo de hornear y sal.", "Incorporá la manteca fría cortando con las manos.", "Agregá el queso rallado.", "Uní con huevo y leche sin amasar de más.", "Estirá 2 cm de alto y cortá con cortante.", "Pintá con huevo batido.", "Horneá a 200°C por 18-20 minutos."] },
      ],
      chicos: [
        { title: "Nuggets de pollo caseros", ingredients: [["Pechuga de pollo", "500", "g", "en trocitos"], ["Huevo", "2", "unidad", nil], ["Pan rallado", "200", "g", nil], ["Queso rallado", "2", "cucharada", nil], ["Aceite de girasol", "300", "ml", "para freír"]], prep: 15, cook: 10, servings: 4, steps: ["Cortá la pechuga en trozos del tamaño de un bocado.", "Batí los huevos.", "Mezclá pan rallado con queso rallado.", "Pasá cada trocito por huevo y después por pan rallado.", "Freí en aceite caliente hasta que estén dorados.", "Escurrí sobre papel absorbente."] },
      ],
      navidad: [
        { title: "Vitel toné", ingredients: [["Peceto", "1", "kg", nil], ["Atún en lata", "2", "unidad", nil], ["Mayonesa", "4", "cucharada", nil], ["Crema de leche", "100", "ml", nil], ["Anchoas", "4", "unidad", nil], ["Alcaparras", "2", "cucharada", nil], ["Limón", "1", "unidad", "jugo"]], prep: 20, cook: 60, servings: 8, steps: ["Herví el peceto en agua con verduras 1 hora.", "Dejá enfriar en el caldo.", "Para la salsa: procesá atún, anchoas, mayonesa, crema y limón.", "Cortá el peceto en rodajas finas.", "Cubrí con la salsa.", "Decorá con alcaparras.", "Llevá a la heladera al menos 2 horas antes de servir."] },
        { title: "Pionono navideño dulce", ingredients: [["Huevo", "4", "unidad", nil], ["Azúcar", "120", "g", nil], ["Harina 000", "120", "g", nil], ["Dulce de leche", "400", "g", nil], ["Crema de leche", "200", "ml", nil], ["Frutilla", "200", "g", nil], ["Durazno", "2", "unidad", "en almíbar"]], prep: 20, cook: 8, servings: 10, steps: ["Batí huevos con azúcar hasta triplicar volumen.", "Incorporá la harina con movimientos envolventes.", "Volcá en placa con papel manteca.", "Horneá a 200°C solo 6-8 minutos.", "Desmoldá caliente sobre un repasador húmedo.", "Enrollalo y dejá enfriar.", "Desenrollá, rellenó con dulce de leche, crema y frutas.", "Volvé a enrollar y decorá."] },
      ],
    }

    # ========================================================================
    # DESCRIPCIONES POR ESTILO DE CHEF
    # ========================================================================
    DESCRIPTIONS = {
      casual: [
        "Una receta que te salva cualquier día de la semana. Re fácil y riquísima.",
        "De esas recetas que hacés una vez y ya no parás más. Posta que sale increíble.",
        "Esto es lo que yo llamo comfort food versión argenta. Simple, rico y al punto.",
        "Si tenés estos ingredientes en la heladera, ya tenés la mitad del laburo hecho.",
        "Receta infalible para cuando no sabés qué cocinar. Siempre funciona.",
        "Ojo que esta receta es adictiva. Avisé después no digan que no les dije.",
        "La versión casera le pasa el trapo a cualquier delivery. Probala y después me contás.",
        "Para los que dicen que no saben cocinar: esta es SU receta. Imposible que salga mal.",
      ],
      pastelero: [
        "Una delicia que combina técnica y sabor. El resultado es espectacular.",
        "El secreto está en respetar las temperaturas y los tiempos. Vale cada minuto.",
        "Esta receta tiene ese punto justo entre lo elegante y lo reconfortante.",
        "Un clásico de la pastelería elevado a otro nivel. Ojo con los tiempos de horno.",
        "Texturas, sabores, aromas. Todo se une en este plato que es pura magia.",
        "Para los que se animan a un desafío dulce. El resultado los va a sorprender.",
      ],
      familiar: [
        "De esas recetas que te hacía la abuela y que siempre volvés a preparar.",
        "Comida de verdad, como la de antes. Para juntar a toda la familia alrededor de la mesa.",
        "Simple, generosa y llena de sabor. Así me gusta cocinar a mí.",
        "Una receta que abraza. Perfecta para esos días en que necesitás algo reconfortante.",
        "Cocina de casa, con ingredientes nobles y mucho amor en cada paso.",
        "El secreto de esta receta es la simpleza. Buenos ingredientes y punto.",
      ],
      moderna: [
        "Fresca, actual y llena de sabor. Con ingredientes de estación queda espectacular.",
        "Una vuelta de tuerca a un clásico, usando lo mejor de la huerta.",
        "Liviana pero con personalidad. Para comer bien sin complicarte.",
        "Ingredientes simples combinados de una manera que te va a sorprender.",
        "Cocina consciente y sabrosa. Porque comer bien no tiene que ser aburrido.",
        "Seasonal y deliciosa. Aprovechá lo que esté fresco en la verdulería.",
      ],
      maternal: [
        "La receta perfecta para hacer con los chicos. Se van a divertir y van a comer de todo.",
        "Dulce, tierna y hecha con mucho amor. Como tiene que ser.",
        "Para las tardes de merienda en familia. Siempre pido que me hagan esta.",
        "Una receta que llenaba mi casa de un aroma increíble. Ahora la comparto con ustedes.",
        "Sencilla y deliciosa. Los más chicos la piden siempre.",
        "Hechas con amor salen mejor. Esta receta no falla nunca.",
      ],
      elegante: [
        "Una receta con técnica francesa adaptada al paladar argentino. Magnifique.",
        "El equilibrio perfecto entre sofisticación y sabor criollo. Un plato para impresionar.",
        "La cocina es precisión y pasión. Esta receta combina las dos cosas.",
        "Ingredientes argentinos, técnica de primer nivel. Así se eleva un plato.",
        "Para los que disfrutan del proceso tanto como del resultado. Cocina con alma.",
        "Simple en concepto, refinada en ejecución. Eso es la buena cocina.",
      ],
      tradicional: [
        "Receta de la cocina argentina de toda la vida. Patrimonio gastronómico puro.",
        "Tradición que se pasa de generación en generación. Hay que preservar estas recetas.",
        "De las recetas que definen nuestra identidad culinaria. Orgullo argentino.",
        "Cocina regional con historia. Cada bocado cuenta una historia de nuestra tierra.",
        "Lo nuestro, lo de siempre. Recetas que son parte de nuestra cultura.",
        "Herencia de las cocinas argentinas. Recetas que merecen ser recordadas.",
      ],
    }

    # ========================================================================
    # VARIANTES DE TÍTULO
    # ========================================================================
    TITLE_MODIFIERS = [
      "", " especial", " casero/a", " a mi manera", " bien argento/a", " de la abuela",
      " express", " fácil", " gourmet", " rústico/a", " tradicional", " criollo/a",
      " para compartir", " del domingo", " de todos los días", " irresistible",
      " súper fácil", " en 30 minutos", " para festejar", " reconfortante",
      " bien cremoso/a", " crocante", " jugoso/a", " tentador/a",
    ]

    # ========================================================================
    # GENERAR RECETAS
    # ========================================================================
    puts "Generando #{TOTAL_TARGET} recetas argentinas curadas..."
    puts "="*60

    all_recipes = []
    used_titles = Set.new

    # Mapeo de categoría symbol a templates
    category_keys = RECIPE_TEMPLATES.keys

    CHEFS.each do |chef_name, chef_info|
      chef_target = (TOTAL_TARGET.to_f / CHEFS.size).ceil
      chef_count = 0
      style = chef_info[:style]
      specialties = chef_info[:specialties]

      # Recorrer las especialidades del chef, priorizando las primeras
      pass = 0
      while chef_count < chef_target
        pass += 1
        specialties.each do |specialty|
          break if chef_count >= chef_target

          templates = RECIPE_TEMPLATES[specialty]
          next unless templates

          templates.each do |template|
            break if chef_count >= chef_target

            # Generar variantes del mismo template
            modifier = if pass == 1
              ""
            else
              TITLE_MODIFIERS.sample
            end

            # Ajustar género del modificador
            base_title = template[:title]
            if modifier.include?("/")
              # Determinar género simple
              modifier = if base_title.match?(/[aá]s?\z/i) || base_title.match?(/torta|tarta|pizza|sopa|ensalada|salsa|tortilla|empanada/i)
                modifier.gsub(/o\/a/, "a")
              else
                modifier.gsub(/o\/a/, "o")
              end
            end

            variant_title = "#{base_title}#{modifier}".strip
            # Agregar nombre del chef si es variante para evitar colisiones
            unique_key = "#{variant_title}-#{chef_name}".downcase
            next if used_titles.include?(unique_key)
            used_titles.add(unique_key)

            description = DESCRIPTIONS[style].sample

            recipe = {
              "title" => variant_title,
              "description" => description,
              "chef_name" => chef_name,
              "prep_time" => template[:prep] + rand(-2..5).clamp(1, 120),
              "cook_time" => template[:cook] + rand(-3..10).clamp(0, 300),
              "servings" => template[:servings] + rand(-1..2).clamp(1, 12),
              "ingredients" => template[:ingredients].map { |name, qty, unit, notes|
                {
                  "name" => name,
                  "quantity" => qty,
                  "unit" => unit,
                  "notes" => notes
                }
              },
              "steps" => template[:steps]
            }

            all_recipes << recipe
            chef_count += 1
          end
        end

        # Si ya recorrimos todo 3 veces y no hay más variantes, salimos
        break if pass > TITLE_MODIFIERS.size
      end

      puts "  #{chef_name}: #{chef_count} recetas"
    end

    # Guardar
    File.write(OUTPUT_FILE, JSON.pretty_generate(all_recipes))
    puts "="*60
    puts "Total: #{all_recipes.size} recetas guardadas en #{OUTPUT_FILE}"
    puts "Archivo: #{OUTPUT_FILE}"
  end
end

desc "Genera recetas argentinas curadas"
task generate_recipes: "recipes:generate"
