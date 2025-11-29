import orderModel from "../models/orderModel.js";
import userModel from "../models/userModel.js";

// Place order with COD
const placeOrder = async (req, res) => {
    try {
        const { userId, items, amount, address } = req.body;

        const orderData = {
            userId,
            items,
            address,
            amount,
            paymentMethod: "COD",
            payment: false,
            date: Date.now()
        };

        const newOrder = new orderModel(orderData);
        await newOrder.save();

        // Clear cart
        await userModel.findByIdAndUpdate(userId, { cartData: {} });

        res.json({ success: true, message: "Order Placed (COD)" });

    } catch (error) {
        console.log(error);
        res.json({ success: false, message: error.message });
    }
};

// Admin: Get all orders
const allOrders = async (req, res) => {
    try {
        const orders = await orderModel.find({});
        res.json({ success: true, orders });
    } catch (error) {
        console.log(error);
        res.json({ success: false, message: error.message });
    }
};

// User: Get user orders
const userOrders = async (req, res) => {
    try {
        const { userId } = req.body;

        const orders = await orderModel.find({ userId });
        res.json({ success: true, orders });

    } catch (error) {
        console.log(error);
        res.json({ success: false, message: error.message });
    }
};

// Admin: Update order status
const updateStatus = async (req, res) => {
    try {
        const { orderId, status } = req.body;

        await orderModel.findByIdAndUpdate(orderId, { status });
        res.json({ success: true, message: "Status Updated" });

    } catch (error) {
        console.log(error);
        res.json({ success: false, message: error.message });
    }
};

export {
    placeOrder,
    allOrders,
    userOrders,
    updateStatus
};
