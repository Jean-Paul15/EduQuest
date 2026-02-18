import QRCode from "qrcode";
import { PDFDocument, StandardFonts, rgb } from "pdf-lib";

export const buildReceiptPdf = async (
  title: string,
  subtitle: string,
  lines: Array<[string, string]>,
  qrValue: string,
) => {
  const doc = await PDFDocument.create();
  const page = doc.addPage([595, 842]);
  const font = await doc.embedFont(StandardFonts.Helvetica);
  const now = new Date();
  const ref = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}-${qrValue.slice(-8)}`;

  page.drawRectangle({ x: 40, y: 740, width: 515, height: 80, color: rgb(0.14, 0.39, 0.92) });
  page.drawText(title, { x: 56, y: 785, size: 22, font, color: rgb(1, 1, 1) });
  page.drawText(subtitle, { x: 56, y: 760, size: 12, font, color: rgb(1, 1, 1) });
  page.drawText("EduQuest", { x: 430, y: 785, size: 12, font, color: rgb(1, 1, 1) });

  page.drawRectangle({ x: 40, y: 680, width: 515, height: 46, color: rgb(0.97, 0.98, 1) });
  page.drawText(`Référence facture: ${ref}`, { x: 56, y: 708, size: 11, font, color: rgb(0.12, 0.18, 0.28) });
  page.drawText(`Date: ${now.toISOString().slice(0, 19).replace("T", " ")}`, { x: 56, y: 690, size: 11, font, color: rgb(0.12, 0.18, 0.28) });

  page.drawRectangle({ x: 40, y: 640, width: 515, height: 26, color: rgb(0.14, 0.39, 0.92) });
  page.drawText("Détail", { x: 56, y: 648, size: 11, font, color: rgb(1, 1, 1) });
  page.drawText("Valeur", { x: 315, y: 648, size: 11, font, color: rgb(1, 1, 1) });

  let y = 628;
  lines.slice(0, 14).forEach(([key, value], i) => {
    page.drawRectangle({
      x: 40, y: y - 16, width: 515, height: 20,
      color: i % 2 === 0 ? rgb(0.99, 0.99, 0.99) : rgb(1, 1, 1),
    });
    page.drawText(key, { x: 56, y: y - 9, size: 10, font, color: rgb(0.1, 0.12, 0.17) });
    page.drawText(value || "-", { x: 315, y: y - 9, size: 10, font, color: rgb(0.1, 0.12, 0.17) });
    y -= 20;
  });

  const qrDataUrl = await QRCode.toDataURL(qrValue, { margin: 1, width: 240 });
  const qrBytes = Buffer.from(qrDataUrl.replace(/^data:image\/png;base64,/, ""), "base64");
  const qr = await doc.embedPng(qrBytes);
  page.drawImage(qr, { x: 56, y: 180, width: 160, height: 160 });
  page.drawText(`Code QR: ${qrValue}`, { x: 56, y: 165, size: 10, font, color: rgb(0.45, 0.45, 0.45) });
  page.drawText("Document généré automatiquement par EduQuest.", { x: 56, y: 146, size: 10, font, color: rgb(0.45, 0.45, 0.45) });
  page.drawText("Conserve ce reçu pour vérification et support.", { x: 56, y: 132, size: 10, font, color: rgb(0.45, 0.45, 0.45) });

  return doc.save();
};
