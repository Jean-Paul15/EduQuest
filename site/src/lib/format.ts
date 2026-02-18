export const formatDate = (value: string) =>
  new Intl.DateTimeFormat("fr-TG", {
    dateStyle: "medium",
    timeStyle: "short",
  }).format(new Date(value));

export const formatMoney = (value: number | null | undefined) => {
  const amount = Number(value ?? 0);
  return new Intl.NumberFormat("fr-TG", {
    style: "currency",
    currency: "XOF",
    maximumFractionDigits: 0,
  }).format(amount);
};
