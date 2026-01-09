const cds = require("@sap/cds");

// CAP Test-Helper initialisieren
cds.test(__dirname + "/..");

describe("Order Service", () => {
  let OrderService;

  beforeAll(async () => {
    OrderService = await cds.connect.to("OrderService");
  });

  describe("Orders Entity", () => {
    it("should return all orders", async () => {
      const { Orders } = OrderService.entities;
      const orders = await SELECT.from(Orders);
      expect(orders).toBeDefined();
      expect(Array.isArray(orders)).toBe(true);
      expect(orders.length).toBeGreaterThan(0);
    });

    it("should have required fields on orders", async () => {
      const { Orders } = OrderService.entities;
      const orders = await SELECT.from(Orders).limit(1);

      if (orders.length > 0) {
        const order = orders[0];
        expect(order).toHaveProperty("ID");
        expect(order).toHaveProperty("orderNumber");
        expect(order).toHaveProperty("status_code");
      }
    });

    it("should filter orders by status", async () => {
      const { Orders } = OrderService.entities;
      const newOrders = await SELECT.from(Orders).where({ status_code: "NEW" });

      newOrders.forEach((order) => {
        expect(order.status_code).toBe("NEW");
      });
    });

    it("should have customer association", async () => {
      const { Orders } = OrderService.entities;
      const orders = await SELECT.from(Orders).limit(1);

      if (orders.length > 0) {
        expect(orders[0]).toHaveProperty("customer_ID");
      }
    });
  });

  describe("OrderItems Entity", () => {
    it("should return all order items", async () => {
      const { OrderItems } = OrderService.entities;
      const items = await SELECT.from(OrderItems);
      expect(items).toBeDefined();
      expect(Array.isArray(items)).toBe(true);
    });

    it("should have quantity and price fields", async () => {
      const { OrderItems } = OrderService.entities;
      const items = await SELECT.from(OrderItems).limit(5);

      items.forEach((item) => {
        expect(item).toHaveProperty("quantity");
        expect(item).toHaveProperty("unitPrice");
      });
    });
  });

  describe("OrderStatus Entity", () => {
    it("should return all order statuses", async () => {
      const { OrderStatus } = OrderService.entities;
      const statuses = await SELECT.from(OrderStatus);
      expect(statuses).toBeDefined();
      expect(statuses.length).toBeGreaterThan(0);
    });

    it("should contain expected status codes", async () => {
      const { OrderStatus } = OrderService.entities;
      const statuses = await SELECT.from(OrderStatus);
      const codes = statuses.map((s) => s.code);

      expect(codes).toContain("NEW");
      expect(codes).toContain("CONFIRMED");
      expect(codes).toContain("DELIVERED");
    });
  });
});
