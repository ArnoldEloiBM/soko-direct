//small function pulled out of the screen so it can be unit tested
//on its own without needing to build the whole widget tree.
double calculateOfferTotal(double pricePerKg, int quantityKg) {
  return pricePerKg * quantityKg;
}