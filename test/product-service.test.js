const cds = require("@sap/cds");

// CAP Test-Helper initialisieren
cds.test(__dirname + "/..");

describe("Product Service", () => {
  let ProductService;

  beforeAll(async () => {
    ProductService = await cds.connect.to("ProductService");
  });

  describe("Products Entity", () => {
    it("should return all active products", async () => {
      const { Products } = ProductService.entities;
      const products = await SELECT.from(Products).where({ isActive: true });
      expect(products).toBeDefined();
      expect(Array.isArray(products)).toBe(true);
    });

    it("should have required product fields", async () => {
      const { Products } = ProductService.entities;
      const products = await SELECT.from(Products).limit(1);

      if (products.length > 0) {
        const product = products[0];
        expect(product).toHaveProperty("ID");
        expect(product).toHaveProperty("productNumber");
        expect(product).toHaveProperty("name");
        expect(product).toHaveProperty("basePrice");
      }
    });

    it("should have valid price values", async () => {
      const { Products } = ProductService.entities;
      const products = await SELECT.from(Products).limit(10);

      products.forEach((product) => {
        if (product.basePrice !== null) {
          expect(product.basePrice).toBeGreaterThanOrEqual(0);
        }
      });
    });

    it("should have stock quantity", async () => {
      const { Products } = ProductService.entities;
      const products = await SELECT.from(Products).limit(5);

      products.forEach((product) => {
        expect(product).toHaveProperty("stockQuantity");
      });
    });
  });

  describe("ProductCategories Entity", () => {
    it("should return all categories", async () => {
      const { ProductCategories } = ProductService.entities;
      const categories = await SELECT.from(ProductCategories);
      expect(categories).toBeDefined();
      expect(categories.length).toBeGreaterThan(0);
    });

    it("should have category names", async () => {
      const { ProductCategories } = ProductService.entities;
      const categories = await SELECT.from(ProductCategories).limit(3);

      categories.forEach((cat) => {
        expect(cat).toHaveProperty("name");
        expect(cat.name).toBeTruthy();
      });
    });
  });

  describe("Suppliers Entity", () => {
    it("should return all suppliers", async () => {
      const { Suppliers } = ProductService.entities;
      const suppliers = await SELECT.from(Suppliers);
      expect(suppliers).toBeDefined();
      expect(suppliers.length).toBeGreaterThan(0);
    });

    it("should have contact information", async () => {
      const { Suppliers } = ProductService.entities;
      const suppliers = await SELECT.from(Suppliers).limit(3);

      suppliers.forEach((supplier) => {
        expect(supplier).toHaveProperty("name");
        expect(supplier).toHaveProperty("email");
      });
    });

    it("should have valid supplier data", async () => {
      const { Suppliers } = ProductService.entities;
      const suppliers = await SELECT.from(Suppliers).limit(1);

      if (suppliers.length > 0) {
        const supplier = suppliers[0];
        expect(supplier).toHaveProperty("supplierNumber");
        expect(supplier).toHaveProperty("isActive");
      }
    });
  });
});
