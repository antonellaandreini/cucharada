namespace :recipes do
  desc "Add missing recipe categories: healthy, vegetable tarts, classic desserts, stews, cakes, puddings"
  task add_missing: :environment do
    $stdout.sync = true

    cucharada_user = User.find_by!(email: "cucharada@cucharada.app")
    created = 0
    skipped = 0

    MISSING_RECIPES.each do |data|
      if Recipe.exists?(title: data[:title], user: cucharada_user)
        skipped += 1
        next
      end

      recipe = Recipe.new(
        user: cucharada_user,
        title: data[:title],
        description: data[:description],
        chef_name: data[:chef],
        prep_time: data[:prep_time],
        cook_time: data[:cook_time],
        servings: data[:servings],
        source_type: "cucharada",
        visibility: "public"
      )

      data[:ingredients].each do |ing|
        ingredient = find_or_create_ingredient(ing[:name])
        recipe.recipe_ingredients.build(
          ingredient: ingredient,
          quantity: ing[:qty],
          unit: ing[:unit],
          notes: ing[:notes]
        )
      end

      data[:steps].each_with_index do |instruction, idx|
        recipe.recipe_steps.build(step_number: idx + 1, instruction: instruction)
      end

      if recipe.save
        created += 1
        # Auto-tag
        auto_tag(recipe)
        print "."
      else
        puts "\nError: #{data[:title]} - #{recipe.errors.full_messages.join(', ')}"
      end
    end

    puts "\n\nCreated #{created} recipes (#{skipped} already existed)"
    puts "Total curated: #{Recipe.where(source_type: 'cucharada').count}"
  end
end

def find_or_create_ingredient(name)
  Ingredient.where("name ILIKE ?", name).first ||
    Ingredient.create!(name: name, category: "Otros")
end

def auto_tag(recipe)
  title = recipe.title.downcase
  tag_map = {
    "Vegano" => %w[vegano vegana tofu],
    "Vegetariano" => %w[vegetariano vegetariana],
    "Ensaladas" => %w[ensalada],
    "Tartas" => %w[tarta quiche],
    "Postres" => %w[torta budín pavlova tiramisú cheesecake lemon mousse panna brownie profiteroles],
    "Sopas" => %w[sopa puchero caldo],
    "Guisos" => %w[guiso estofado puchero],
    "Carnes" => %w[carne bife lomo cerdo pollo],
    "Pescados" => %w[salmón merluza trucha pescado],
    "Arroces" => %w[arroz risotto],
    "Pastas" => %w[pasta fideos],
    "Dulce" => %w[torta budín pavlova tiramisú flan dulce chocolate],
    "Rápido" => nil # calculated
  }

  tag_map.each do |tag_name, keywords|
    tag = Tag.find_by(name: tag_name)
    next unless tag

    if keywords
      if keywords.any? { |kw| title.include?(kw) }
        RecipeTag.find_or_create_by!(recipe: recipe, tag: tag)
      end
    end
  end

  # Rápido tag
  total = (recipe.prep_time || 0) + (recipe.cook_time || 0)
  if total > 0 && total <= 30
    rapid = Tag.find_by(name: "Rápido")
    RecipeTag.find_or_create_by!(recipe: recipe, tag: rapid) if rapid
  end
end

CHEFS = [
  "Narda Lepes", "Paulina Cocina", "Maru Botana", "Dolli Irigoyen",
  "Mauricio Betular", "Christophe Krywonis", "Ariel Rodriguez Palacios"
].freeze

def chef(idx)
  CHEFS[idx % CHEFS.size]
end

# rubocop:disable Layout/LineLength, Metrics/CollectionLiteralLength
MISSING_RECIPES = [
  # ==================== TARTAS DE VERDURAS ====================
  {
    title: "Tarta de zucchini y queso",
    description: "Tarta liviana de zucchini rallado con queso cremoso, perfecta para una cena rápida.",
    chef: "Narda Lepes", prep_time: 20, cook_time: 35, servings: 8,
    ingredients: [
      { name: "Tapa de tarta", qty: "1", unit: "unidad" },
      { name: "Zucchini", qty: "3", unit: "unidades", notes: "rallados y escurridos" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Crema de leche", qty: "200", unit: "ml" },
      { name: "Queso cremoso", qty: "150", unit: "g", notes: "en cubos" },
      { name: "Queso rallado", qty: "50", unit: "g" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" },
      { name: "Pimienta", qty: nil, unit: nil, notes: "a gusto" },
      { name: "Nuez moscada", qty: nil, unit: nil, notes: "un toque" }
    ],
    steps: [
      "Precalentar el horno a 180°C. Forrar una tartera con la tapa de tarta y pincharla con un tenedor.",
      "Rallar los zucchinis y escurrirlos bien apretándolos con las manos para sacar el exceso de agua.",
      "En un bowl mezclar los huevos, la crema, sal, pimienta y nuez moscada.",
      "Agregar los zucchinis escurridos y el queso cremoso en cubos. Mezclar bien.",
      "Volcar el relleno sobre la tapa de tarta. Espolvorear con queso rallado.",
      "Hornear 35 minutos o hasta que esté dorada y firme. Dejar reposar 5 minutos antes de cortar."
    ]
  },
  {
    title: "Tarta de berenjena, tomate y mozzarella",
    description: "Tarta estilo caprese con berenjenas grilladas, rodajas de tomate y mozzarella derretida.",
    chef: "Dolli Irigoyen", prep_time: 25, cook_time: 40, servings: 8,
    ingredients: [
      { name: "Tapa de tarta", qty: "1", unit: "unidad" },
      { name: "Berenjena", qty: "2", unit: "unidades", notes: "en rodajas" },
      { name: "Tomate", qty: "3", unit: "unidades", notes: "en rodajas" },
      { name: "Mozzarella", qty: "200", unit: "g", notes: "en rodajas" },
      { name: "Huevo", qty: "2", unit: "unidades" },
      { name: "Crema de leche", qty: "150", unit: "ml" },
      { name: "Albahaca", qty: "1", unit: "puñado" },
      { name: "Aceite de oliva", qty: "2", unit: "cucharadas" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Cortar las berenjenas en rodajas de 1 cm, salar y dejar 15 minutos. Secar con papel.",
      "Grillar o dorar las rodajas de berenjena en una sartén con aceite de oliva. Reservar.",
      "Precalentar el horno a 180°C. Forrar una tartera con la tapa de tarta.",
      "Disponer las berenjenas, el tomate y la mozzarella alternando en la tarta.",
      "Batir los huevos con la crema y sal. Verter sobre las verduras.",
      "Hornear 40 minutos hasta que esté dorada. Servir con hojas de albahaca fresca."
    ]
  },
  {
    title: "Tarta de calabaza y queso de cabra",
    description: "Tarta otoñal con puré de calabaza especiado y queso de cabra desmenuzado por encima.",
    chef: "Christophe Krywonis", prep_time: 30, cook_time: 40, servings: 8,
    ingredients: [
      { name: "Tapa de tarta", qty: "1", unit: "unidad" },
      { name: "Calabaza", qty: "500", unit: "g", notes: "en cubos" },
      { name: "Queso de cabra", qty: "120", unit: "g" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Crema de leche", qty: "150", unit: "ml" },
      { name: "Cebolla", qty: "1", unit: "unidad" },
      { name: "Nuez moscada", qty: nil, unit: nil, notes: "un toque" },
      { name: "Tomillo", qty: nil, unit: nil, notes: "unas ramitas" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Hervir o cocinar al vapor la calabaza hasta que esté tierna. Hacer un puré y dejar enfriar.",
      "Rehogar la cebolla picada fina en manteca hasta que esté transparente.",
      "Mezclar el puré de calabaza con la cebolla, huevos, crema, nuez moscada y sal.",
      "Forrar la tartera con la masa y volcar el relleno.",
      "Desmenuzar el queso de cabra por encima y agregar hojitas de tomillo.",
      "Hornear a 180°C por 40 minutos. Servir tibia."
    ]
  },
  {
    title: "Tarta de puerro y panceta",
    description: "Clásica tarta de puerro cremosa con panceta crocante, una combinación irresistible.",
    chef: "Paulina Cocina", prep_time: 20, cook_time: 35, servings: 8,
    ingredients: [
      { name: "Tapa de tarta", qty: "1", unit: "unidad" },
      { name: "Puerro", qty: "4", unit: "unidades", notes: "la parte blanca y verde claro" },
      { name: "Panceta", qty: "150", unit: "g", notes: "en tiritas" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Crema de leche", qty: "200", unit: "ml" },
      { name: "Queso rallado", qty: "50", unit: "g" },
      { name: "Manteca", qty: "20", unit: "g" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" },
      { name: "Pimienta", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Lavar bien los puerros y cortarlos en rodajas finas.",
      "Dorar la panceta en una sartén hasta que esté crocante. Retirar y reservar.",
      "En la misma sartén con la grasa de la panceta, agregar manteca y cocinar los puerros a fuego bajo 10 minutos.",
      "Batir los huevos con la crema, sal y pimienta.",
      "Forrar la tartera con la masa. Distribuir los puerros y la panceta. Verter la mezcla de huevos.",
      "Espolvorear con queso rallado y hornear a 180°C por 35 minutos."
    ]
  },
  {
    title: "Tarta de espinaca y ricota",
    description: "Un clásico argentino: tarta de espinaca cremosa con ricota, nuez moscada y queso.",
    chef: "Maru Botana", prep_time: 20, cook_time: 35, servings: 8,
    ingredients: [
      { name: "Tapa de tarta", qty: "2", unit: "unidades", notes: "base y tapa" },
      { name: "Espinaca", qty: "2", unit: "atados", notes: "lavada y hervida" },
      { name: "Ricota", qty: "300", unit: "g" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Cebolla", qty: "1", unit: "unidad" },
      { name: "Queso rallado", qty: "60", unit: "g" },
      { name: "Nuez moscada", qty: nil, unit: nil, notes: "a gusto" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Hervir la espinaca 2 minutos, escurrir muy bien y picar.",
      "Rehogar la cebolla picada hasta que esté transparente.",
      "Mezclar la espinaca, cebolla, ricota, huevos, queso rallado, nuez moscada y sal.",
      "Forrar la tartera con una tapa de tarta. Volcar el relleno.",
      "Cubrir con la segunda tapa, sellar los bordes y pinchar con un tenedor. Pincelar con huevo.",
      "Hornear a 200°C por 35 minutos hasta que esté bien dorada."
    ]
  },
  {
    title: "Tarta de tomate y albahaca",
    description: "Tarta simple y veraniega con tomates maduros, albahaca fresca y mostaza.",
    chef: "Narda Lepes", prep_time: 15, cook_time: 30, servings: 6,
    ingredients: [
      { name: "Tapa de tarta", qty: "1", unit: "unidad" },
      { name: "Tomate", qty: "5", unit: "unidades", notes: "maduros, en rodajas" },
      { name: "Mostaza", qty: "2", unit: "cucharadas" },
      { name: "Queso rallado", qty: "80", unit: "g" },
      { name: "Albahaca", qty: "1", unit: "puñado" },
      { name: "Aceite de oliva", qty: "2", unit: "cucharadas" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" },
      { name: "Pimienta", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Precalentar el horno a 200°C. Forrar una tartera con la masa y pincharla.",
      "Pincelar la base con mostaza de forma pareja.",
      "Espolvorear la mitad del queso rallado sobre la mostaza.",
      "Disponer las rodajas de tomate superpuestas. Salpimentar.",
      "Cubrir con el resto del queso rallado y un chorrito de aceite de oliva.",
      "Hornear 30 minutos. Servir con albahaca fresca por encima."
    ]
  },
  {
    title: "Tarta de choclo cremosa",
    description: "Tarta con granos de choclo, crema y queso, el sabor del verano argentino.",
    chef: "Dolli Irigoyen", prep_time: 15, cook_time: 35, servings: 8,
    ingredients: [
      { name: "Tapa de tarta", qty: "1", unit: "unidad" },
      { name: "Choclo", qty: "4", unit: "unidades", notes: "desgranados o 2 latas" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Crema de leche", qty: "200", unit: "ml" },
      { name: "Cebolla", qty: "1", unit: "unidad" },
      { name: "Queso cremoso", qty: "150", unit: "g" },
      { name: "Pimentón", qty: "1", unit: "cucharadita" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Hervir los choclos y desgranar. Si usás lata, escurrir bien.",
      "Rehogar la cebolla picada hasta dorar.",
      "Mezclar los granos de choclo, cebolla, huevos, crema, pimentón y sal.",
      "Forrar la tartera y volcar el relleno. Agregar el queso cremoso en cubos hundidos en la mezcla.",
      "Hornear a 180°C por 35 minutos hasta que esté firme y dorada.",
      "Dejar reposar 10 minutos antes de cortar."
    ]
  },

  # ==================== PUCHERO Y ESTOFADOS ====================
  {
    title: "Puchero criollo",
    description: "El gran clásico de los domingos argentinos: carne, verduras y legumbres en un caldo reconfortante.",
    chef: "Dolli Irigoyen", prep_time: 30, cook_time: 120, servings: 8,
    ingredients: [
      { name: "Falda", qty: "800", unit: "g" },
      { name: "Chorizo", qty: "4", unit: "unidades" },
      { name: "Papa", qty: "4", unit: "unidades" },
      { name: "Batata", qty: "2", unit: "unidades" },
      { name: "Choclo", qty: "2", unit: "unidades", notes: "cortados al medio" },
      { name: "Zapallo", qty: "300", unit: "g", notes: "en trozos grandes" },
      { name: "Zanahoria", qty: "3", unit: "unidades" },
      { name: "Cebolla", qty: "2", unit: "unidades" },
      { name: "Puerro", qty: "2", unit: "unidades" },
      { name: "Repollo", qty: "1/4", unit: "unidad" },
      { name: "Sal gruesa", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Poner la falda en una olla grande con agua fría. Llevar a hervor y espumar.",
      "Agregar las cebollas enteras y el puerro. Cocinar a fuego bajo 1 hora.",
      "Incorporar las papas, batatas, zanahorias y zapallo. Cocinar 30 minutos más.",
      "Agregar los choclos, el repollo y los chorizos. Cocinar 20 minutos.",
      "Servir las carnes cortadas y las verduras en una fuente. Acompañar con el caldo en tazas.",
      "Opcionalmente servir con salsa criolla a un lado."
    ]
  },
  {
    title: "Puchero de gallina",
    description: "Versión suave y delicada del puchero con gallina, ideal para días fríos y reconfortarse.",
    chef: "Paulina Cocina", prep_time: 20, cook_time: 150, servings: 6,
    ingredients: [
      { name: "Gallina", qty: "1", unit: "entera", notes: "trozada" },
      { name: "Papa", qty: "3", unit: "unidades" },
      { name: "Batata", qty: "2", unit: "unidades" },
      { name: "Zanahoria", qty: "3", unit: "unidades" },
      { name: "Choclo", qty: "2", unit: "unidades" },
      { name: "Zapallo", qty: "300", unit: "g" },
      { name: "Cebolla", qty: "1", unit: "unidad" },
      { name: "Perejil", qty: "1", unit: "ramita" },
      { name: "Sal gruesa", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Colocar la gallina trozada en una olla grande con agua fría. Llevar a hervor y espumar bien.",
      "Agregar la cebolla entera, perejil y sal. Cocinar a fuego mínimo 2 horas.",
      "Agregar las verduras más duras (zanahoria, papa, batata) y cocinar 30 minutos.",
      "Incorporar el zapallo y el choclo cortado. Cocinar 20 minutos más.",
      "Retirar las piezas de gallina y las verduras. Colar el caldo.",
      "Servir en fuente con la gallina y las verduras. Acompañar con el caldo colado."
    ]
  },
  {
    title: "Estofado de carne con papas",
    description: "Estofado sustancioso de carne tierna con papas doradas en salsa de tomate y vino tinto.",
    chef: "Ariel Rodriguez Palacios", prep_time: 25, cook_time: 120, servings: 6,
    ingredients: [
      { name: "Carne", qty: "800", unit: "g", notes: "para estofado, en cubos" },
      { name: "Papa", qty: "4", unit: "unidades", notes: "en cubos" },
      { name: "Zanahoria", qty: "3", unit: "unidades", notes: "en rodajas" },
      { name: "Cebolla", qty: "2", unit: "unidades" },
      { name: "Tomate", qty: "3", unit: "unidades", notes: "perita, pelados" },
      { name: "Vino tinto", qty: "200", unit: "ml" },
      { name: "Caldo de carne", qty: "500", unit: "ml" },
      { name: "Ajo", qty: "3", unit: "dientes" },
      { name: "Laurel", qty: "2", unit: "hojas" },
      { name: "Pimentón", qty: "1", unit: "cucharadita" },
      { name: "Aceite", qty: "3", unit: "cucharadas" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Sellar la carne en cubos en una olla con aceite caliente. Retirar y reservar.",
      "En la misma olla, rehogar la cebolla y el ajo picados hasta que estén dorados.",
      "Agregar el pimentón, cocinar 30 segundos y desglasar con el vino tinto.",
      "Incorporar los tomates picados, el laurel y el caldo. Volver a poner la carne.",
      "Cocinar tapado a fuego bajo 1 hora. Agregar las zanahorias y papas.",
      "Cocinar 40 minutos más hasta que la carne esté tierna y las verduras cocidas. Rectificar sal."
    ]
  },
  {
    title: "Estofado de pollo con vegetales",
    description: "Estofado liviano de pollo con verduras de estación en salsa de tomate casera.",
    chef: "Narda Lepes", prep_time: 20, cook_time: 60, servings: 4,
    ingredients: [
      { name: "Pollo", qty: "8", unit: "piezas", notes: "pata y muslo" },
      { name: "Papa", qty: "3", unit: "unidades" },
      { name: "Zanahoria", qty: "2", unit: "unidades" },
      { name: "Cebolla", qty: "1", unit: "unidad" },
      { name: "Morrón", qty: "1", unit: "unidad", notes: "rojo" },
      { name: "Tomate", qty: "400", unit: "g", notes: "triturados" },
      { name: "Caldo de pollo", qty: "300", unit: "ml" },
      { name: "Orégano", qty: "1", unit: "cucharadita" },
      { name: "Aceite de oliva", qty: "2", unit: "cucharadas" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Dorar las piezas de pollo en aceite en una olla. Retirar y reservar.",
      "Rehogar la cebolla, el morrón y la zanahoria cortados.",
      "Agregar el tomate triturado, caldo, orégano y sal.",
      "Devolver el pollo a la olla. Cocinar tapado 30 minutos a fuego bajo.",
      "Agregar las papas en cubos y cocinar 25 minutos más.",
      "Servir caliente con pan para mojar en la salsa."
    ]
  },
  {
    title: "Estofado de cerdo con batatas",
    description: "Estofado de cerdo meloso con batatas que se deshacen, especiado con comino y pimentón.",
    chef: "Christophe Krywonis", prep_time: 20, cook_time: 90, servings: 6,
    ingredients: [
      { name: "Cerdo", qty: "800", unit: "g", notes: "bondiola, en cubos" },
      { name: "Batata", qty: "3", unit: "unidades", notes: "en cubos grandes" },
      { name: "Cebolla", qty: "2", unit: "unidades" },
      { name: "Ajo", qty: "4", unit: "dientes" },
      { name: "Tomate", qty: "400", unit: "g", notes: "triturados" },
      { name: "Caldo de verduras", qty: "400", unit: "ml" },
      { name: "Comino", qty: "1", unit: "cucharadita" },
      { name: "Pimentón ahumado", qty: "1", unit: "cucharadita" },
      { name: "Aceite", qty: "2", unit: "cucharadas" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Sellar la bondiola en cubos en una olla con aceite bien caliente. Reservar.",
      "Rehogar la cebolla y el ajo. Agregar comino y pimentón ahumado.",
      "Incorporar el tomate y cocinar 5 minutos. Agregar el caldo y la carne.",
      "Cocinar tapado a fuego bajo 45 minutos.",
      "Agregar las batatas y cocinar 35 minutos más hasta que todo esté tierno.",
      "La salsa debe quedar espesa. Si queda líquida, destapar y reducir 5 minutos."
    ]
  },
  {
    title: "Estofado de lentejas con verduras",
    description: "Estofado vegetariano contundente de lentejas con verduras, nutritivo y económico.",
    chef: "Paulina Cocina", prep_time: 15, cook_time: 45, servings: 6,
    ingredients: [
      { name: "Lentejas", qty: "400", unit: "g" },
      { name: "Zanahoria", qty: "2", unit: "unidades" },
      { name: "Papa", qty: "2", unit: "unidades" },
      { name: "Cebolla", qty: "1", unit: "unidad" },
      { name: "Tomate", qty: "2", unit: "unidades", notes: "pelados" },
      { name: "Ajo", qty: "2", unit: "dientes" },
      { name: "Pimentón", qty: "1", unit: "cucharadita" },
      { name: "Comino", qty: "1/2", unit: "cucharadita" },
      { name: "Laurel", qty: "1", unit: "hoja" },
      { name: "Aceite de oliva", qty: "2", unit: "cucharadas" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Remojar las lentejas 1 hora o usar directas si son de cocción rápida.",
      "Rehogar la cebolla y el ajo en aceite. Agregar el pimentón y comino.",
      "Incorporar las zanahorias y papas en cubos. Cocinar 3 minutos.",
      "Agregar el tomate picado, las lentejas escurridas, el laurel y agua para cubrir.",
      "Cocinar a fuego medio-bajo 40 minutos hasta que las lentejas estén tiernas.",
      "Rectificar sal y servir caliente. Queda mejor al día siguiente."
    ]
  },

  # ==================== POSTRES CLÁSICOS ====================
  {
    title: "Pavlova con frutos rojos",
    description: "Merengue crujiente por fuera y malvavisco por dentro, coronado con crema y frutos rojos.",
    chef: "Mauricio Betular", prep_time: 30, cook_time: 90, servings: 8,
    ingredients: [
      { name: "Clara de huevo", qty: "4", unit: "unidades" },
      { name: "Azúcar", qty: "250", unit: "g" },
      { name: "Maicena", qty: "1", unit: "cucharada" },
      { name: "Vinagre", qty: "1", unit: "cucharadita" },
      { name: "Esencia de vainilla", qty: "1", unit: "cucharadita" },
      { name: "Crema de leche", qty: "300", unit: "ml" },
      { name: "Frutilla", qty: "200", unit: "g" },
      { name: "Arándanos", qty: "100", unit: "g" },
      { name: "Frambuesas", qty: "100", unit: "g" }
    ],
    steps: [
      "Precalentar el horno a 150°C. Forrar una bandeja con papel manteca.",
      "Batir las claras a punto nieve. Agregar el azúcar de a cucharadas sin dejar de batir hasta obtener un merengue firme y brillante.",
      "Incorporar la maicena, el vinagre y la vainilla con movimientos envolventes.",
      "Formar un disco de 20 cm en la bandeja, haciendo un hueco en el centro.",
      "Hornear 90 minutos a 120°C. Apagar el horno y dejar enfriar adentro sin abrir.",
      "Montar la crema batida en el centro y decorar con los frutos rojos."
    ]
  },
  {
    title: "Tiramisú clásico",
    description: "El postre italiano más famoso con capas de café, mascarpone y cacao. Sin horno.",
    chef: "Christophe Krywonis", prep_time: 30, cook_time: 0, servings: 8,
    ingredients: [
      { name: "Queso mascarpone", qty: "500", unit: "g" },
      { name: "Huevo", qty: "4", unit: "unidades", notes: "separar claras y yemas" },
      { name: "Azúcar", qty: "100", unit: "g" },
      { name: "Café", qty: "300", unit: "ml", notes: "espresso frío" },
      { name: "Vainillas", qty: "200", unit: "g" },
      { name: "Cacao amargo", qty: "3", unit: "cucharadas" },
      { name: "Amaretto", qty: "2", unit: "cucharadas", notes: "opcional" }
    ],
    steps: [
      "Batir las yemas con el azúcar hasta que estén cremosas y pálidas.",
      "Agregar el mascarpone y mezclar bien hasta integrar.",
      "Batir las claras a punto nieve e incorporar a la mezcla con movimientos envolventes.",
      "Mezclar el café frío con el amaretto. Mojar las vainillas rápidamente (que no se empapen).",
      "Armar capas: vainillas mojadas, crema de mascarpone, vainillas, crema. Terminar con crema.",
      "Espolvorear cacao amargo por encima. Refrigerar mínimo 4 horas, idealmente toda la noche."
    ]
  },
  {
    title: "Lemon pie",
    description: "Tarta de limón con base crocante de galletitas, relleno cremoso y merengue dorado.",
    chef: "Maru Botana", prep_time: 30, cook_time: 25, servings: 8,
    ingredients: [
      { name: "Galletitas dulces", qty: "250", unit: "g", notes: "tipo Lincoln" },
      { name: "Manteca", qty: "100", unit: "g", notes: "derretida" },
      { name: "Leche condensada", qty: "400", unit: "g" },
      { name: "Limón", qty: "4", unit: "unidades", notes: "jugo y ralladura" },
      { name: "Huevo", qty: "4", unit: "unidades", notes: "separar claras y yemas" },
      { name: "Azúcar", qty: "100", unit: "g", notes: "para el merengue" }
    ],
    steps: [
      "Triturar las galletitas y mezclar con la manteca derretida. Forrar una tartera y llevar al freezer 15 minutos.",
      "Mezclar la leche condensada con las yemas, el jugo de limón y la ralladura.",
      "Verter el relleno sobre la base fría.",
      "Hornear a 180°C por 15 minutos hasta que esté firme.",
      "Batir las claras a punto nieve agregando el azúcar de a poco hasta tener un merengue firme.",
      "Cubrir la tarta con el merengue formando picos. Dorar con soplete o gratinar en el horno."
    ]
  },
  {
    title: "Panna cotta con coulis de frutos rojos",
    description: "Postre italiano de crema cocida, suave como una nube, con salsa de frutos rojos.",
    chef: "Mauricio Betular", prep_time: 15, cook_time: 10, servings: 6,
    ingredients: [
      { name: "Crema de leche", qty: "500", unit: "ml" },
      { name: "Leche", qty: "200", unit: "ml" },
      { name: "Azúcar", qty: "80", unit: "g" },
      { name: "Gelatina sin sabor", qty: "7", unit: "g" },
      { name: "Esencia de vainilla", qty: "1", unit: "cucharadita" },
      { name: "Frutilla", qty: "200", unit: "g", notes: "para el coulis" },
      { name: "Frambuesas", qty: "100", unit: "g", notes: "para el coulis" },
      { name: "Azúcar", qty: "40", unit: "g", notes: "para el coulis" }
    ],
    steps: [
      "Hidratar la gelatina en 3 cucharadas de agua fría por 5 minutos.",
      "Calentar la crema con la leche, el azúcar y la vainilla. No dejar hervir.",
      "Retirar del fuego, agregar la gelatina hidratada y mezclar hasta disolver.",
      "Verter en moldes individuales. Refrigerar mínimo 4 horas.",
      "Para el coulis: cocinar las frutillas y frambuesas con el azúcar 10 minutos. Procesar y colar.",
      "Desmoldar la panna cotta y servir con el coulis de frutos rojos por encima."
    ]
  },
  {
    title: "Profiteroles con chocolate",
    description: "Bolitas de masa choux rellenas de crema pastelera y bañadas en salsa de chocolate.",
    chef: "Mauricio Betular", prep_time: 40, cook_time: 30, servings: 8,
    ingredients: [
      { name: "Agua", qty: "200", unit: "ml" },
      { name: "Manteca", qty: "80", unit: "g" },
      { name: "Harina", qty: "120", unit: "g" },
      { name: "Huevo", qty: "4", unit: "unidades" },
      { name: "Leche", qty: "500", unit: "ml", notes: "para la crema" },
      { name: "Azúcar", qty: "120", unit: "g", notes: "para la crema" },
      { name: "Maicena", qty: "40", unit: "g", notes: "para la crema" },
      { name: "Esencia de vainilla", qty: "1", unit: "cucharadita" },
      { name: "Chocolate", qty: "200", unit: "g", notes: "semiamargo" },
      { name: "Crema de leche", qty: "100", unit: "ml", notes: "para la ganache" }
    ],
    steps: [
      "Hervir el agua con la manteca. Agregar la harina de golpe y mezclar enérgicamente hasta que se despegue.",
      "Pasar a un bowl, dejar entibiar e incorporar los huevos de a uno mezclando bien.",
      "Con manga, formar bolitas en una bandeja enmantecada. Hornear a 200°C por 25 minutos. No abrir el horno.",
      "Crema pastelera: calentar la leche. Aparte mezclar yemas, azúcar y maicena. Verter la leche caliente mezclando. Cocinar hasta espesar.",
      "Rellenar los profiteroles con la crema usando una manga.",
      "Ganache: calentar la crema y verter sobre el chocolate picado. Mezclar. Bañar los profiteroles."
    ]
  },
  {
    title: "Crème brûlée",
    description: "Clásico postre francés de crema de vainilla con costra de caramelo crocante.",
    chef: "Christophe Krywonis", prep_time: 15, cook_time: 45, servings: 6,
    ingredients: [
      { name: "Crema de leche", qty: "500", unit: "ml" },
      { name: "Yema de huevo", qty: "6", unit: "unidades" },
      { name: "Azúcar", qty: "100", unit: "g" },
      { name: "Esencia de vainilla", qty: "1", unit: "cucharadita" },
      { name: "Azúcar", qty: "6", unit: "cucharadas", notes: "para caramelizar" }
    ],
    steps: [
      "Precalentar el horno a 150°C.",
      "Calentar la crema con la vainilla sin que hierva.",
      "Batir las yemas con el azúcar hasta blanquear. Verter la crema caliente en hilo.",
      "Colar y distribuir en ramequines. Colocar en una fuente con agua caliente hasta la mitad.",
      "Hornear a baño María 45 minutos. Deben temblar apenas en el centro.",
      "Refrigerar mínimo 4 horas. Antes de servir, espolvorear azúcar y caramelizar con soplete."
    ]
  },
  {
    title: "Mousse de chocolate",
    description: "Mousse aireada y sedosa de chocolate semiamargo, el postre perfecto para los chocolateros.",
    chef: "Maru Botana", prep_time: 20, cook_time: 0, servings: 6,
    ingredients: [
      { name: "Chocolate", qty: "200", unit: "g", notes: "semiamargo" },
      { name: "Manteca", qty: "30", unit: "g" },
      { name: "Huevo", qty: "4", unit: "unidades", notes: "separar claras y yemas" },
      { name: "Azúcar", qty: "60", unit: "g" },
      { name: "Crema de leche", qty: "200", unit: "ml" }
    ],
    steps: [
      "Derretir el chocolate con la manteca a baño María. Dejar entibiar.",
      "Agregar las yemas una a una al chocolate tibio, mezclando bien.",
      "Batir la crema a medio punto e incorporar al chocolate con movimientos envolventes.",
      "Batir las claras a nieve con el azúcar. Incorporar en dos tandas al chocolate.",
      "Distribuir en copas o vasos. Refrigerar mínimo 3 horas.",
      "Servir con crema batida o virutas de chocolate por encima."
    ]
  },
  {
    title: "Tarta de frutillas con crema pastelera",
    description: "Base de masa sablée con crema pastelera de vainilla y frutillas frescas glaseadas.",
    chef: "Mauricio Betular", prep_time: 40, cook_time: 20, servings: 8,
    ingredients: [
      { name: "Harina", qty: "250", unit: "g" },
      { name: "Manteca", qty: "125", unit: "g", notes: "fría" },
      { name: "Azúcar impalpable", qty: "80", unit: "g" },
      { name: "Huevo", qty: "1", unit: "unidad" },
      { name: "Leche", qty: "400", unit: "ml", notes: "para la crema" },
      { name: "Azúcar", qty: "100", unit: "g", notes: "para la crema" },
      { name: "Maicena", qty: "35", unit: "g" },
      { name: "Esencia de vainilla", qty: "1", unit: "cucharadita" },
      { name: "Frutilla", qty: "500", unit: "g" },
      { name: "Mermelada de damasco", qty: "3", unit: "cucharadas", notes: "para el brillo" }
    ],
    steps: [
      "Masa: mezclar la harina con la manteca fría en cubos hasta obtener un arenado. Agregar azúcar y huevo. Formar disco, envolver y refrigerar 30 minutos.",
      "Estirar la masa y forrar un molde de tarta. Pinchar y hornear con peso a 180°C por 20 minutos. Enfriar.",
      "Crema pastelera: calentar la leche. Mezclar yemas, azúcar y maicena. Verter la leche caliente. Cocinar a fuego bajo revolviendo hasta espesar. Agregar vainilla.",
      "Cubrir la crema con film en contacto y enfriar completamente.",
      "Rellenar la masa con la crema pastelera. Disponer las frutillas cortadas por encima.",
      "Calentar la mermelada con una cucharada de agua y pincelar las frutillas para dar brillo."
    ]
  },

  # ==================== TORTAS VARIADAS ====================
  {
    title: "Torta de zanahoria con frosting de queso crema",
    description: "Torta húmeda y especiada de zanahoria rallada con un frosting cremoso irresistible.",
    chef: "Maru Botana", prep_time: 25, cook_time: 40, servings: 10,
    ingredients: [
      { name: "Zanahoria", qty: "3", unit: "unidades", notes: "ralladas" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Azúcar", qty: "250", unit: "g" },
      { name: "Aceite", qty: "200", unit: "ml" },
      { name: "Harina", qty: "250", unit: "g" },
      { name: "Polvo de hornear", qty: "2", unit: "cucharaditas" },
      { name: "Canela", qty: "2", unit: "cucharaditas" },
      { name: "Nuez", qty: "100", unit: "g", notes: "picadas" },
      { name: "Queso crema", qty: "200", unit: "g", notes: "para frosting" },
      { name: "Manteca", qty: "50", unit: "g", notes: "para frosting" },
      { name: "Azúcar impalpable", qty: "150", unit: "g", notes: "para frosting" }
    ],
    steps: [
      "Batir los huevos con el azúcar y el aceite hasta integrar.",
      "Agregar la harina tamizada con el polvo de hornear y la canela.",
      "Incorporar las zanahorias ralladas y las nueces.",
      "Verter en un molde enmantecado de 24 cm. Hornear a 180°C por 40 minutos.",
      "Frosting: batir el queso crema con la manteca blanda y el azúcar impalpable.",
      "Dejar enfriar la torta completamente. Cubrir con el frosting y decorar con nueces."
    ]
  },
  {
    title: "Torta de limón glaseada",
    description: "Torta cítrica y húmeda con un glaseado de limón brillante y acidito.",
    chef: "Paulina Cocina", prep_time: 20, cook_time: 40, servings: 8,
    ingredients: [
      { name: "Harina", qty: "250", unit: "g" },
      { name: "Azúcar", qty: "200", unit: "g" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Manteca", qty: "120", unit: "g", notes: "derretida" },
      { name: "Limón", qty: "3", unit: "unidades", notes: "jugo y ralladura" },
      { name: "Yogur natural", qty: "150", unit: "g" },
      { name: "Polvo de hornear", qty: "2", unit: "cucharaditas" },
      { name: "Azúcar impalpable", qty: "150", unit: "g", notes: "para glaseado" }
    ],
    steps: [
      "Batir los huevos con el azúcar hasta que estén espumosos.",
      "Agregar la manteca derretida, el yogur, la ralladura y el jugo de 2 limones.",
      "Incorporar la harina tamizada con el polvo de hornear.",
      "Hornear en molde enmantecado a 180°C por 40 minutos.",
      "Glaseado: mezclar el azúcar impalpable con el jugo del limón restante.",
      "Dejar entibiar la torta y verter el glaseado por encima dejando que chorree."
    ]
  },
  {
    title: "Torta de banana con chocolate",
    description: "Torta súper húmeda de banana madura con chips de chocolate, ideal para la merienda.",
    chef: "Narda Lepes", prep_time: 15, cook_time: 45, servings: 8,
    ingredients: [
      { name: "Banana", qty: "4", unit: "unidades", notes: "bien maduras" },
      { name: "Huevo", qty: "2", unit: "unidades" },
      { name: "Azúcar", qty: "180", unit: "g" },
      { name: "Manteca", qty: "80", unit: "g", notes: "derretida" },
      { name: "Harina", qty: "250", unit: "g" },
      { name: "Polvo de hornear", qty: "2", unit: "cucharaditas" },
      { name: "Chocolate", qty: "100", unit: "g", notes: "en chips o picado" },
      { name: "Esencia de vainilla", qty: "1", unit: "cucharadita" }
    ],
    steps: [
      "Pisar las bananas con un tenedor hasta obtener un puré.",
      "Agregar los huevos, el azúcar, la manteca derretida y la vainilla. Mezclar.",
      "Incorporar la harina con el polvo de hornear tamizados.",
      "Agregar los chips de chocolate y mezclar.",
      "Verter en un molde enmantecado. Hornear a 180°C por 45 minutos.",
      "Dejar enfriar 10 minutos en el molde antes de desmoldar."
    ]
  },
  {
    title: "Torta de coco",
    description: "Torta esponjosa de coco rallado con un baño blanco de coco, una delicia tropical.",
    chef: "Dolli Irigoyen", prep_time: 20, cook_time: 35, servings: 8,
    ingredients: [
      { name: "Harina", qty: "200", unit: "g" },
      { name: "Coco rallado", qty: "100", unit: "g" },
      { name: "Azúcar", qty: "200", unit: "g" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Manteca", qty: "100", unit: "g" },
      { name: "Leche de coco", qty: "200", unit: "ml" },
      { name: "Polvo de hornear", qty: "2", unit: "cucharaditas" },
      { name: "Azúcar impalpable", qty: "100", unit: "g", notes: "para el baño" },
      { name: "Coco rallado", qty: "50", unit: "g", notes: "para decorar" }
    ],
    steps: [
      "Batir la manteca con el azúcar hasta cremar. Agregar los huevos de a uno.",
      "Incorporar alternando la harina tamizada con polvo de hornear y la leche de coco.",
      "Agregar el coco rallado y mezclar.",
      "Hornear en molde enmantecado a 180°C por 35 minutos.",
      "Baño: mezclar el azúcar impalpable con 2 cucharadas de leche de coco.",
      "Verter sobre la torta tibia y espolvorear con coco rallado."
    ]
  },
  {
    title: "Torta selva negra",
    description: "Clásica torta alemana de chocolate con cerezas, crema chantilly y virutas de chocolate.",
    chef: "Mauricio Betular", prep_time: 45, cook_time: 35, servings: 10,
    ingredients: [
      { name: "Harina", qty: "180", unit: "g" },
      { name: "Cacao amargo", qty: "60", unit: "g" },
      { name: "Azúcar", qty: "250", unit: "g" },
      { name: "Huevo", qty: "4", unit: "unidades" },
      { name: "Manteca", qty: "80", unit: "g" },
      { name: "Leche", qty: "200", unit: "ml" },
      { name: "Polvo de hornear", qty: "2", unit: "cucharaditas" },
      { name: "Cerezas", qty: "400", unit: "g", notes: "en almíbar, escurridas" },
      { name: "Crema de leche", qty: "500", unit: "ml" },
      { name: "Chocolate", qty: "100", unit: "g", notes: "para virutas" }
    ],
    steps: [
      "Batir huevos con azúcar hasta triplicar volumen. Agregar manteca derretida.",
      "Tamizar harina, cacao y polvo de hornear. Incorporar alternando con la leche.",
      "Hornear en molde de 24 cm a 180°C por 35 minutos. Enfriar y cortar en 3 capas.",
      "Batir la crema a punto chantilly con 3 cucharadas de azúcar.",
      "Armar: capa de bizcochuelo, crema, cerezas, repetir. Cubrir toda la torta con crema.",
      "Decorar con virutas de chocolate y cerezas reservadas por encima."
    ]
  },
  {
    title: "Torta de ricota",
    description: "Torta cremosa de ricota al estilo italiano, suave y con aroma a limón.",
    chef: "Christophe Krywonis", prep_time: 20, cook_time: 50, servings: 8,
    ingredients: [
      { name: "Ricota", qty: "500", unit: "g" },
      { name: "Azúcar", qty: "180", unit: "g" },
      { name: "Huevo", qty: "4", unit: "unidades" },
      { name: "Harina", qty: "60", unit: "g" },
      { name: "Limón", qty: "1", unit: "unidad", notes: "ralladura" },
      { name: "Esencia de vainilla", qty: "1", unit: "cucharadita" },
      { name: "Pasas de uva", qty: "80", unit: "g", notes: "opcional" }
    ],
    steps: [
      "Batir la ricota con el azúcar hasta integrar bien.",
      "Agregar los huevos de a uno, mezclando entre cada adición.",
      "Incorporar la harina, la ralladura de limón y la vainilla.",
      "Agregar las pasas si se desea.",
      "Verter en un molde enmantecado y enharinado de 24 cm.",
      "Hornear a 170°C por 50 minutos. Apagar el horno y dejar 10 minutos adentro. Espolvorear con azúcar impalpable."
    ]
  },

  # ==================== BUDINES ====================
  {
    title: "Budín de pan",
    description: "El clásico budín de pan argentino con salsa de caramelo, húmedo y reconfortante.",
    chef: "Maru Botana", prep_time: 20, cook_time: 50, servings: 8,
    ingredients: [
      { name: "Pan", qty: "400", unit: "g", notes: "del día anterior" },
      { name: "Leche", qty: "500", unit: "ml" },
      { name: "Huevo", qty: "4", unit: "unidades" },
      { name: "Azúcar", qty: "200", unit: "g" },
      { name: "Esencia de vainilla", qty: "1", unit: "cucharadita" },
      { name: "Pasas de uva", qty: "80", unit: "g" },
      { name: "Azúcar", qty: "100", unit: "g", notes: "para el caramelo" }
    ],
    steps: [
      "Cortar el pan en trozos y remojar en la leche caliente 15 minutos.",
      "Hacer caramelo con los 100 g de azúcar y cubrir el fondo de una budinera.",
      "Desmenuzar el pan remojado con las manos. Agregar huevos, azúcar y vainilla.",
      "Incorporar las pasas. Mezclar bien.",
      "Verter en la budinera caramelizada.",
      "Hornear a baño María a 180°C por 50 minutos. Dejar enfriar y desmoldar invertido."
    ]
  },
  {
    title: "Budín de banana",
    description: "Budín húmedo y aromático de bananas maduras, perfecto para acompañar el mate.",
    chef: "Paulina Cocina", prep_time: 15, cook_time: 50, servings: 8,
    ingredients: [
      { name: "Banana", qty: "4", unit: "unidades", notes: "bien maduras" },
      { name: "Huevo", qty: "2", unit: "unidades" },
      { name: "Azúcar", qty: "150", unit: "g" },
      { name: "Manteca", qty: "80", unit: "g", notes: "derretida" },
      { name: "Harina", qty: "250", unit: "g" },
      { name: "Polvo de hornear", qty: "2", unit: "cucharaditas" },
      { name: "Esencia de vainilla", qty: "1", unit: "cucharadita" },
      { name: "Nuez", qty: "50", unit: "g", notes: "picadas, opcional" }
    ],
    steps: [
      "Pisar 3 bananas con tenedor. Cortar la restante en rodajas para decorar.",
      "Batir los huevos con el azúcar. Agregar la manteca derretida y la vainilla.",
      "Incorporar las bananas pisadas.",
      "Agregar la harina tamizada con el polvo de hornear y las nueces.",
      "Verter en budinera enmantecada. Colocar las rodajas de banana encima.",
      "Hornear a 180°C por 50 minutos. Dejar enfriar antes de desmoldar."
    ]
  },
  {
    title: "Budín de limón",
    description: "Budín cítrico y húmedo con glaseado de limón, fresco y aromático.",
    chef: "Narda Lepes", prep_time: 15, cook_time: 45, servings: 8,
    ingredients: [
      { name: "Harina", qty: "250", unit: "g" },
      { name: "Azúcar", qty: "180", unit: "g" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Manteca", qty: "100", unit: "g", notes: "derretida" },
      { name: "Limón", qty: "2", unit: "unidades", notes: "jugo y ralladura" },
      { name: "Yogur natural", qty: "100", unit: "g" },
      { name: "Polvo de hornear", qty: "2", unit: "cucharaditas" },
      { name: "Azúcar impalpable", qty: "100", unit: "g", notes: "para glaseado" }
    ],
    steps: [
      "Batir los huevos con el azúcar. Agregar manteca derretida, yogur, ralladura y jugo de 1 limón.",
      "Incorporar la harina con el polvo de hornear tamizados.",
      "Verter en budinera enmantecada y hornear a 180°C por 45 minutos.",
      "Glaseado: mezclar el azúcar impalpable con el jugo del limón restante.",
      "Desmoldar el budín tibio y verter el glaseado por encima.",
      "Dejar secar el glaseado antes de servir."
    ]
  },
  {
    title: "Budín de naranja",
    description: "Budín perfumado de naranja con trocitos de cáscara confitada, ideal con el té.",
    chef: "Dolli Irigoyen", prep_time: 15, cook_time: 50, servings: 8,
    ingredients: [
      { name: "Harina", qty: "250", unit: "g" },
      { name: "Azúcar", qty: "180", unit: "g" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Aceite", qty: "100", unit: "ml" },
      { name: "Naranja", qty: "2", unit: "unidades", notes: "jugo y ralladura" },
      { name: "Polvo de hornear", qty: "2", unit: "cucharaditas" }
    ],
    steps: [
      "Batir los huevos con el azúcar hasta espumar.",
      "Agregar el aceite, el jugo y la ralladura de las naranjas.",
      "Incorporar la harina tamizada con el polvo de hornear.",
      "Verter en budinera enmantecada.",
      "Hornear a 180°C por 50 minutos.",
      "Opcional: pincelar con almíbar de naranja (jugo + azúcar) al sacar del horno."
    ]
  },
  {
    title: "Budín de chocolate",
    description: "Budín intenso de chocolate, húmedo y esponjoso, para los amantes del cacao.",
    chef: "Mauricio Betular", prep_time: 15, cook_time: 45, servings: 8,
    ingredients: [
      { name: "Harina", qty: "200", unit: "g" },
      { name: "Cacao amargo", qty: "50", unit: "g" },
      { name: "Azúcar", qty: "200", unit: "g" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Manteca", qty: "100", unit: "g", notes: "derretida" },
      { name: "Leche", qty: "150", unit: "ml" },
      { name: "Polvo de hornear", qty: "2", unit: "cucharaditas" },
      { name: "Chocolate", qty: "100", unit: "g", notes: "en chips, opcional" }
    ],
    steps: [
      "Batir los huevos con el azúcar hasta cremar.",
      "Agregar la manteca derretida y la leche.",
      "Tamizar la harina, el cacao y el polvo de hornear. Incorporar a la mezcla.",
      "Agregar los chips de chocolate si se desea.",
      "Verter en budinera enmantecada y hornear a 180°C por 45 minutos.",
      "Dejar enfriar 15 minutos antes de desmoldar. Se puede espolvorear con azúcar impalpable."
    ]
  },
  {
    title: "Budín marmolado",
    description: "El budín bicolor clásico con vetas de vainilla y chocolate, lindo para regalar.",
    chef: "Maru Botana", prep_time: 20, cook_time: 50, servings: 8,
    ingredients: [
      { name: "Harina", qty: "250", unit: "g" },
      { name: "Azúcar", qty: "200", unit: "g" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Manteca", qty: "120", unit: "g" },
      { name: "Leche", qty: "150", unit: "ml" },
      { name: "Polvo de hornear", qty: "2", unit: "cucharaditas" },
      { name: "Cacao amargo", qty: "30", unit: "g" },
      { name: "Esencia de vainilla", qty: "1", unit: "cucharadita" }
    ],
    steps: [
      "Batir la manteca con el azúcar hasta cremar. Agregar los huevos de a uno.",
      "Incorporar la harina con polvo de hornear alternando con la leche. Agregar vainilla.",
      "Separar un tercio de la masa y mezclarle el cacao con una cucharada de leche.",
      "Verter la masa blanca en la budinera. Agregar la masa de chocolate en el centro.",
      "Con un palillo hacer movimientos de zigzag para crear el efecto marmolado.",
      "Hornear a 180°C por 50 minutos. Dejar enfriar antes de desmoldar."
    ]
  },
  {
    title: "Budín de manzana",
    description: "Budín con trocitos de manzana y canela, húmedo y perfumado.",
    chef: "Ariel Rodriguez Palacios", prep_time: 20, cook_time: 50, servings: 8,
    ingredients: [
      { name: "Manzana", qty: "3", unit: "unidades", notes: "peladas y en cubos" },
      { name: "Harina", qty: "250", unit: "g" },
      { name: "Azúcar", qty: "180", unit: "g" },
      { name: "Huevo", qty: "3", unit: "unidades" },
      { name: "Manteca", qty: "100", unit: "g", notes: "derretida" },
      { name: "Canela", qty: "1", unit: "cucharadita" },
      { name: "Polvo de hornear", qty: "2", unit: "cucharaditas" },
      { name: "Azúcar", qty: "2", unit: "cucharadas", notes: "para espolvorear" }
    ],
    steps: [
      "Batir los huevos con el azúcar. Agregar la manteca derretida.",
      "Incorporar la harina con polvo de hornear y canela tamizados.",
      "Agregar las manzanas en cubos y mezclar.",
      "Verter en budinera enmantecada. Espolvorear con azúcar y canela.",
      "Hornear a 180°C por 50 minutos.",
      "Dejar enfriar antes de desmoldar."
    ]
  },

  # ==================== RECETAS SALUDABLES ====================
  {
    title: "Bowl de quinoa con vegetales asados",
    description: "Bowl nutritivo de quinoa con verduras asadas, palta y aderezo de tahini.",
    chef: "Narda Lepes", prep_time: 15, cook_time: 30, servings: 2,
    ingredients: [
      { name: "Quinoa", qty: "1", unit: "taza" },
      { name: "Calabaza", qty: "200", unit: "g", notes: "en cubos" },
      { name: "Zucchini", qty: "1", unit: "unidad" },
      { name: "Morrón", qty: "1", unit: "unidad", notes: "rojo" },
      { name: "Palta", qty: "1", unit: "unidad" },
      { name: "Semillas de girasol", qty: "2", unit: "cucharadas" },
      { name: "Aceite de oliva", qty: "2", unit: "cucharadas" },
      { name: "Limón", qty: "1", unit: "unidad" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Cocinar la quinoa en agua con sal por 15 minutos. Escurrir y reservar.",
      "Cortar la calabaza, el zucchini y el morrón en cubos. Condimentar con aceite, sal y pimienta.",
      "Asar las verduras en horno a 200°C por 25 minutos.",
      "Armar los bowls: base de quinoa, verduras asadas y palta en rodajas.",
      "Espolvorear con semillas de girasol.",
      "Aderezar con un chorrito de aceite de oliva y jugo de limón."
    ]
  },
  {
    title: "Ensalada tibia de lentejas y vegetales",
    description: "Ensalada nutritiva de lentejas con verduras asadas, rúcula y vinagreta de mostaza.",
    chef: "Narda Lepes", prep_time: 15, cook_time: 25, servings: 4,
    ingredients: [
      { name: "Lentejas", qty: "300", unit: "g", notes: "cocidas" },
      { name: "Zanahoria", qty: "2", unit: "unidades", notes: "en rodajas" },
      { name: "Remolacha", qty: "1", unit: "unidad", notes: "en cubos" },
      { name: "Rúcula", qty: "100", unit: "g" },
      { name: "Queso de cabra", qty: "80", unit: "g" },
      { name: "Aceite de oliva", qty: "3", unit: "cucharadas" },
      { name: "Vinagre", qty: "1", unit: "cucharada" },
      { name: "Mostaza", qty: "1", unit: "cucharadita" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Asar la zanahoria y la remolacha con aceite a 200°C por 25 minutos.",
      "Cocinar las lentejas si no están cocidas. Escurrir.",
      "Preparar la vinagreta mezclando aceite, vinagre, mostaza y sal.",
      "Mezclar las lentejas tibias con las verduras asadas.",
      "Servir sobre un colchón de rúcula. Desmenuzar el queso de cabra encima.",
      "Aderezar con la vinagreta de mostaza."
    ]
  },
  {
    title: "Salmón al horno con vegetales",
    description: "Filet de salmón jugoso con cama de vegetales al horno, saludable y en una sola fuente.",
    chef: "Christophe Krywonis", prep_time: 15, cook_time: 25, servings: 2,
    ingredients: [
      { name: "Salmón", qty: "2", unit: "filetes" },
      { name: "Brócoli", qty: "200", unit: "g", notes: "en ramitos" },
      { name: "Tomate cherry", qty: "200", unit: "g" },
      { name: "Zucchini", qty: "1", unit: "unidad", notes: "en rodajas" },
      { name: "Aceite de oliva", qty: "3", unit: "cucharadas" },
      { name: "Limón", qty: "1", unit: "unidad" },
      { name: "Ajo", qty: "2", unit: "dientes" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" },
      { name: "Pimienta", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Precalentar el horno a 200°C.",
      "Disponer el brócoli, los tomates cherry y el zucchini en una fuente. Condimentar con aceite, sal y ajo picado.",
      "Hornear las verduras 10 minutos.",
      "Colocar los filetes de salmón sobre las verduras. Salpimentar y agregar jugo de limón.",
      "Hornear 15 minutos más hasta que el salmón esté cocido pero jugoso.",
      "Servir directo de la fuente con rodajas de limón."
    ]
  },
  {
    title: "Wok de vegetales con tofu",
    description: "Salteado rápido de vegetales con tofu crocante y salsa de soja, listo en 15 minutos.",
    chef: "Narda Lepes", prep_time: 10, cook_time: 10, servings: 2,
    ingredients: [
      { name: "Tofu", qty: "200", unit: "g", notes: "firme, en cubos" },
      { name: "Brócoli", qty: "150", unit: "g" },
      { name: "Zanahoria", qty: "1", unit: "unidad", notes: "en juliana" },
      { name: "Morrón", qty: "1", unit: "unidad", notes: "en tiras" },
      { name: "Zucchini", qty: "1", unit: "unidad", notes: "en medias lunas" },
      { name: "Salsa de soja", qty: "3", unit: "cucharadas" },
      { name: "Aceite de sésamo", qty: "1", unit: "cucharada" },
      { name: "Jengibre", qty: "1", unit: "cucharadita", notes: "rallado" },
      { name: "Semillas de sésamo", qty: "1", unit: "cucharada" }
    ],
    steps: [
      "Dorar el tofu en cubos en una sartén o wok con aceite bien caliente. Reservar.",
      "En el mismo wok, saltear las verduras a fuego fuerte 3-4 minutos (que queden crocantes).",
      "Agregar el jengibre rallado y saltear 30 segundos.",
      "Incorporar la salsa de soja y el aceite de sésamo. Devolver el tofu.",
      "Saltear 1 minuto más integrando todo.",
      "Servir con semillas de sésamo por encima. Acompañar con arroz si se desea."
    ]
  },
  {
    title: "Pollo grillado con ensalada mediterránea",
    description: "Pechuga de pollo grillada marinada en limón con ensalada fresca estilo mediterráneo.",
    chef: "Dolli Irigoyen", prep_time: 15, cook_time: 15, servings: 2,
    ingredients: [
      { name: "Pechuga de pollo", qty: "2", unit: "unidades" },
      { name: "Limón", qty: "1", unit: "unidad" },
      { name: "Tomate", qty: "2", unit: "unidades" },
      { name: "Pepino", qty: "1", unit: "unidad" },
      { name: "Cebolla morada", qty: "1/2", unit: "unidad" },
      { name: "Aceitunas", qty: "50", unit: "g" },
      { name: "Aceite de oliva", qty: "3", unit: "cucharadas" },
      { name: "Orégano", qty: "1", unit: "cucharadita" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Marinar las pechugas con jugo de limón, aceite, orégano y sal por 10 minutos.",
      "Grillar las pechugas en plancha o sartén caliente, 6-7 minutos por lado.",
      "Cortar el tomate, pepino y cebolla morada. Mezclar con aceitunas.",
      "Condimentar la ensalada con aceite de oliva, sal y orégano.",
      "Dejar reposar el pollo 3 minutos antes de cortar en fetas.",
      "Servir el pollo sobre la ensalada."
    ]
  },
  {
    title: "Tortilla de vegetales al horno",
    description: "Tortilla esponjosa al horno con zucchini, morrón, espinaca y queso, sin vuelta.",
    chef: "Paulina Cocina", prep_time: 15, cook_time: 25, servings: 4,
    ingredients: [
      { name: "Huevo", qty: "6", unit: "unidades" },
      { name: "Zucchini", qty: "1", unit: "unidad", notes: "rallado" },
      { name: "Morrón", qty: "1", unit: "unidad", notes: "en cubitos" },
      { name: "Espinaca", qty: "100", unit: "g", notes: "fresca" },
      { name: "Queso rallado", qty: "60", unit: "g" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" },
      { name: "Pimienta", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Precalentar el horno a 200°C.",
      "Batir los huevos con sal, pimienta y queso rallado.",
      "Agregar el zucchini rallado y escurrido, el morrón en cubitos y la espinaca.",
      "Verter en una fuente para horno aceitada.",
      "Hornear 25 minutos hasta que esté firme y dorada.",
      "Dejar reposar 5 minutos, cortar en porciones y servir."
    ]
  },
  {
    title: "Ensalada Caesar con pollo grillado",
    description: "Clásica ensalada Caesar con lechuga crocante, pollo grillado, crutones y parmesano.",
    chef: "Ariel Rodriguez Palacios", prep_time: 15, cook_time: 15, servings: 2,
    ingredients: [
      { name: "Pechuga de pollo", qty: "2", unit: "unidades" },
      { name: "Lechuga", qty: "1", unit: "planta", notes: "romana o criolla" },
      { name: "Pan", qty: "2", unit: "rebanadas", notes: "para crutones" },
      { name: "Queso parmesano", qty: "60", unit: "g", notes: "en lascas" },
      { name: "Mayonesa", qty: "3", unit: "cucharadas" },
      { name: "Limón", qty: "1", unit: "unidad" },
      { name: "Ajo", qty: "1", unit: "diente" },
      { name: "Aceite de oliva", qty: "2", unit: "cucharadas" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Grillar las pechugas salpimentadas 6-7 minutos por lado. Cortar en tiras.",
      "Cortar el pan en cubos, mezclar con aceite y dorar en horno a 200°C por 8 minutos.",
      "Aderezo: mezclar mayonesa, jugo de limón, ajo rallado, una cucharada de agua y sal.",
      "Lavar y trozar la lechuga en un bowl.",
      "Agregar el pollo, crutones y lascas de parmesano.",
      "Aderezar justo antes de servir."
    ]
  },
  {
    title: "Tabulé de quinoa",
    description: "Ensalada fresca estilo tabulé con quinoa, pepino, tomate y mucho perejil y limón.",
    chef: "Narda Lepes", prep_time: 15, cook_time: 15, servings: 4,
    ingredients: [
      { name: "Quinoa", qty: "200", unit: "g" },
      { name: "Tomate", qty: "3", unit: "unidades", notes: "en cubitos" },
      { name: "Pepino", qty: "1", unit: "unidad", notes: "en cubitos" },
      { name: "Cebolla morada", qty: "1/2", unit: "unidad", notes: "picada fina" },
      { name: "Perejil", qty: "1", unit: "atado grande", notes: "picado fino" },
      { name: "Menta", qty: "1", unit: "puñado", notes: "picada" },
      { name: "Limón", qty: "2", unit: "unidades" },
      { name: "Aceite de oliva", qty: "4", unit: "cucharadas" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Cocinar la quinoa en agua con sal por 15 minutos. Escurrir y enfriar.",
      "Cortar los tomates y el pepino en cubitos pequeños. Picar la cebolla morada fina.",
      "Picar el perejil y la menta bien finos.",
      "Mezclar todo con la quinoa fría.",
      "Aderezar con el jugo de los limones, aceite de oliva y sal.",
      "Refrigerar 30 minutos antes de servir para que se integren los sabores."
    ]
  },

  # ==================== MÁS VARIEDAD ====================
  {
    title: "Risotto de hongos",
    description: "Risotto cremoso con hongos mixtos, parmesano y un toque de vino blanco.",
    chef: "Christophe Krywonis", prep_time: 15, cook_time: 30, servings: 4,
    ingredients: [
      { name: "Arroz", qty: "300", unit: "g", notes: "arborio o carnaroli" },
      { name: "Hongos", qty: "300", unit: "g", notes: "mixtos, laminados" },
      { name: "Caldo de verduras", qty: "1", unit: "litro", notes: "caliente" },
      { name: "Cebolla", qty: "1", unit: "unidad" },
      { name: "Vino blanco", qty: "100", unit: "ml" },
      { name: "Queso parmesano", qty: "80", unit: "g", notes: "rallado" },
      { name: "Manteca", qty: "30", unit: "g" },
      { name: "Aceite de oliva", qty: "2", unit: "cucharadas" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Saltear los hongos en aceite a fuego fuerte hasta dorar. Reservar.",
      "Rehogar la cebolla picada en manteca. Agregar el arroz y nacarar 2 minutos.",
      "Desglasar con el vino blanco y revolver hasta que se absorba.",
      "Agregar el caldo caliente de a cucharones, revolviendo, esperando que se absorba antes de agregar más.",
      "Cuando el arroz esté al dente (unos 18 minutos), incorporar los hongos y el parmesano.",
      "Agregar un toque de manteca, mezclar y servir de inmediato."
    ]
  },
  {
    title: "Tarta caprese de berenjena",
    description: "Tarta inspirada en la caprese con berenjenas asadas, tomate fresco y mozzarella.",
    chef: "Dolli Irigoyen", prep_time: 20, cook_time: 35, servings: 6,
    ingredients: [
      { name: "Tapa de tarta", qty: "1", unit: "unidad" },
      { name: "Berenjena", qty: "2", unit: "unidades" },
      { name: "Tomate", qty: "3", unit: "unidades" },
      { name: "Mozzarella", qty: "200", unit: "g" },
      { name: "Albahaca", qty: "1", unit: "puñado" },
      { name: "Aceite de oliva", qty: "2", unit: "cucharadas" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Cortar las berenjenas en rodajas, salar y dejar reposar 10 minutos. Secar.",
      "Grillar las rodajas de berenjena con aceite de oliva.",
      "Forrar la tartera con la masa.",
      "Alternar capas de berenjena, tomate en rodajas y mozzarella.",
      "Hornear a 200°C por 35 minutos hasta dorar.",
      "Servir con hojas de albahaca fresca."
    ]
  },
  {
    title: "Canelones de verdura y ricota",
    description: "Canelones caseros rellenos de espinaca, ricota y nuez moscada, con salsa blanca gratinada.",
    chef: "Paulina Cocina", prep_time: 40, cook_time: 30, servings: 6,
    ingredients: [
      { name: "Tapas para canelones", qty: "12", unit: "unidades" },
      { name: "Espinaca", qty: "2", unit: "atados" },
      { name: "Ricota", qty: "400", unit: "g" },
      { name: "Huevo", qty: "1", unit: "unidad" },
      { name: "Queso rallado", qty: "80", unit: "g" },
      { name: "Nuez moscada", qty: nil, unit: nil, notes: "a gusto" },
      { name: "Leche", qty: "500", unit: "ml", notes: "para salsa blanca" },
      { name: "Harina", qty: "40", unit: "g", notes: "para salsa blanca" },
      { name: "Manteca", qty: "40", unit: "g", notes: "para salsa blanca" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Hervir la espinaca 2 minutos. Escurrir, exprimir y picar fino.",
      "Mezclar la espinaca con la ricota, el huevo, la mitad del queso rallado, nuez moscada y sal.",
      "Salsa blanca: derretir la manteca, agregar la harina y cocinar 1 minuto. Incorporar la leche de a poco revolviendo. Cocinar hasta espesar.",
      "Rellenar cada tapa con la mezcla y enrollar.",
      "Disponer en fuente para horno. Cubrir con la salsa blanca y el queso rallado restante.",
      "Gratinar en horno a 200°C por 25-30 minutos hasta dorar."
    ]
  },
  {
    title: "Berenjenas rellenas gratinadas",
    description: "Mitades de berenjena rellenas con carne, tomate y queso gratinado. Plato completo.",
    chef: "Ariel Rodriguez Palacios", prep_time: 20, cook_time: 40, servings: 4,
    ingredients: [
      { name: "Berenjena", qty: "4", unit: "unidades", notes: "medianas" },
      { name: "Carne picada", qty: "300", unit: "g" },
      { name: "Cebolla", qty: "1", unit: "unidad" },
      { name: "Tomate", qty: "2", unit: "unidades", notes: "pelados y picados" },
      { name: "Mozzarella", qty: "150", unit: "g" },
      { name: "Queso rallado", qty: "40", unit: "g" },
      { name: "Ajo", qty: "2", unit: "dientes" },
      { name: "Aceite de oliva", qty: "2", unit: "cucharadas" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Cortar las berenjenas al medio y vaciar la pulpa dejando 1 cm de borde. Picar la pulpa.",
      "Hornear las mitades vacías 15 minutos a 200°C.",
      "Rehogar la cebolla, ajo y carne picada. Agregar la pulpa de berenjena y el tomate.",
      "Cocinar 10 minutos. Salpimentar.",
      "Rellenar las berenjenas con la mezcla. Cubrir con mozzarella y queso rallado.",
      "Gratinar en horno 15-20 minutos hasta que el queso esté dorado y burbujeante."
    ]
  },
  {
    title: "Zapallitos rellenos",
    description: "Zapallitos redondos rellenos con carne, arroz y queso, un clásico de la cocina argentina.",
    chef: "Dolli Irigoyen", prep_time: 25, cook_time: 35, servings: 4,
    ingredients: [
      { name: "Zapallito", qty: "8", unit: "unidades", notes: "redondos" },
      { name: "Carne picada", qty: "300", unit: "g" },
      { name: "Arroz", qty: "100", unit: "g", notes: "cocido" },
      { name: "Cebolla", qty: "1", unit: "unidad" },
      { name: "Tomate", qty: "1", unit: "unidad" },
      { name: "Queso rallado", qty: "60", unit: "g" },
      { name: "Huevo", qty: "1", unit: "unidad" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" },
      { name: "Orégano", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Hervir los zapallitos enteros 10 minutos. Cortar la tapa y ahuecar con una cuchara. Picar la pulpa.",
      "Rehogar la cebolla y la carne picada. Agregar el tomate picado y la pulpa del zapallito.",
      "Mezclar con el arroz cocido, huevo y la mitad del queso rallado. Salpimentar.",
      "Rellenar los zapallitos con la mezcla.",
      "Espolvorear con queso rallado y orégano.",
      "Hornear a 200°C por 25 minutos hasta gratinar."
    ]
  },
  {
    title: "Milanesa de berenjena al horno",
    description: "Rodajas de berenjena empanadas y horneadas, crocantes por fuera, tiernas por dentro. Opción saludable.",
    chef: "Paulina Cocina", prep_time: 20, cook_time: 25, servings: 4,
    ingredients: [
      { name: "Berenjena", qty: "2", unit: "unidades", notes: "grandes" },
      { name: "Huevo", qty: "2", unit: "unidades" },
      { name: "Pan rallado", qty: "200", unit: "g" },
      { name: "Queso rallado", qty: "50", unit: "g" },
      { name: "Orégano", qty: "1", unit: "cucharadita" },
      { name: "Ajo en polvo", qty: "1/2", unit: "cucharadita" },
      { name: "Aceite de oliva", qty: "2", unit: "cucharadas", notes: "en spray o para pincelar" },
      { name: "Sal", qty: nil, unit: nil, notes: "a gusto" }
    ],
    steps: [
      "Cortar las berenjenas en rodajas de 1 cm de grosor.",
      "Salar las rodajas y dejar reposar 10 minutos. Secar con papel.",
      "Mezclar el pan rallado con queso rallado, orégano y ajo en polvo.",
      "Pasar las rodajas por huevo batido y luego por la mezcla de pan rallado.",
      "Disponer en bandeja con papel manteca. Rociar con aceite de oliva.",
      "Hornear a 200°C por 25 minutos, dando vuelta a mitad de cocción."
    ]
  },

].freeze
# rubocop:enable Layout/LineLength, Metrics/CollectionLiteralLength
