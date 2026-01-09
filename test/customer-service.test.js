const cds = require("@sap/cds");

// CAP Test-Helper initialisieren
cds.test(__dirname + "/..");

describe("Customer Service", () => {
  let CustomerService;

  beforeAll(async () => {
    CustomerService = await cds.connect.to("CustomerService");
  });

  describe("Customers Entity", () => {
    it("should return all customers", async () => {
      const { Customers } = CustomerService.entities;
      const customers = await SELECT.from(Customers);
      expect(customers).toBeDefined();
      expect(Array.isArray(customers)).toBe(true);
      expect(customers.length).toBeGreaterThan(0);
    });

    it("should have required customer fields", async () => {
      const { Customers } = CustomerService.entities;
      const customers = await SELECT.from(Customers).limit(1);

      if (customers.length > 0) {
        const customer = customers[0];
        expect(customer).toHaveProperty("ID");
        expect(customer).toHaveProperty("customerNumber");
        expect(customer).toHaveProperty("companyName");
      }
    });

    it("should filter customers by type", async () => {
      const { Customers } = CustomerService.entities;
      const businessCustomers = await SELECT.from(Customers).where({
        customerType_code: "B2B",
      });

      businessCustomers.forEach((customer) => {
        expect(customer.customerType_code).toBe("B2B");
      });
    });

    it("should filter customers by status", async () => {
      const { Customers } = CustomerService.entities;
      const activeCustomers = await SELECT.from(Customers).where({
        status_code: "ACTIVE",
      });

      activeCustomers.forEach((customer) => {
        expect(customer.status_code).toBe("ACTIVE");
      });
    });

    it("should have credit limit field", async () => {
      const { Customers } = CustomerService.entities;
      const customers = await SELECT.from(Customers).limit(5);

      customers.forEach((customer) => {
        expect(customer).toHaveProperty("creditLimit");
      });
    });
  });

  describe("CustomerAddresses Entity", () => {
    it("should return all addresses", async () => {
      const { CustomerAddresses } = CustomerService.entities;
      const addresses = await SELECT.from(CustomerAddresses);
      expect(addresses).toBeDefined();
      expect(Array.isArray(addresses)).toBe(true);
    });

    it("should have address fields", async () => {
      const { CustomerAddresses } = CustomerService.entities;
      const addresses = await SELECT.from(CustomerAddresses).limit(3);

      addresses.forEach((addr) => {
        expect(addr).toHaveProperty("street");
        expect(addr).toHaveProperty("city");
        expect(addr).toHaveProperty("postalCode");
      });
    });
  });

  describe("CustomerTypes Entity", () => {
    it("should return customer types for value help", async () => {
      const { CustomerTypes } = CustomerService.entities;
      const types = await SELECT.from(CustomerTypes);
      expect(types).toBeDefined();
      expect(types.length).toBeGreaterThan(0);
    });

    it("should contain expected type codes", async () => {
      const { CustomerTypes } = CustomerService.entities;
      const types = await SELECT.from(CustomerTypes);
      const codes = types.map((t) => t.code);

      expect(codes).toContain("B2C");
      expect(codes).toContain("B2B");
    });
  });

  describe("CustomerStatus Entity", () => {
    it("should return customer statuses for value help", async () => {
      const { CustomerStatus } = CustomerService.entities;
      const statuses = await SELECT.from(CustomerStatus);
      expect(statuses).toBeDefined();
      expect(statuses.length).toBeGreaterThan(0);
    });

    it("should contain expected status codes", async () => {
      const { CustomerStatus } = CustomerService.entities;
      const statuses = await SELECT.from(CustomerStatus);
      const codes = statuses.map((s) => s.code);

      expect(codes).toContain("ACTIVE");
      expect(codes).toContain("BLOCKED");
    });
  });
});
